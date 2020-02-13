-- 	https://www.sisense.com/blog/spline-interpolation-in-sql/ 
-- 	https://github.com/bytefish/PostgresTimeseriesAnalysis
-- 	https://bytefish.de/blog/postgresql_interpolation/ 
-- 	https://content.pivotal.io/blog/time-series-analysis-part-3-resampling-and-interpolation


USE Northwind; 

DROP TABLE IF EXISTS xy; 

CREATE TABLE xy 
	SELECT CAST(tmp.x AS DOUBLE PRECISION) AS x, tmp.y  
		FROM (SELECT ROW_NUMBER() OVER (ORDER BY OrderDate) AS x, Freight AS y FROM Orders WHERE Freight > 10 AND Freight < 30) tmp
        WHERE tmp.x % 4 = 0 ORDER BY 1; 

select * from xy;
SELECT min(x), max(x), min(y), max(y) FROM xy; 


WITH RECURSIVE
   x_series(input_x) AS (
    select
      min(x)
    from
      xy
    union all
    select
      input_x + 0.5
    from
      x_series
    where
      input_x + 0.5 <= (select max(x) from xy)
)
, x_coordinate AS (
  select
    input_x
    , max(x) over(order by input_x) as previous_x
  from
    x_series
  left join
    xy on abs(x_series.input_x - xy.x) < 0.001
)
, fullxy AS (
	SELECT x, y, 
			LAG(x,1) OVER (ORDER BY x) AS x0, 
			LAG(y,1) OVER (ORDER BY x) AS y0, 
            x AS x1, 
            y AS y1, 
 			LEAD(x,1) OVER (ORDER BY x) AS x2, 
			LEAD(y,1) OVER (ORDER BY x) AS y2, 
 			LEAD(x,2) OVER (ORDER BY x) AS x3, 
			LEAD(y,2) OVER (ORDER BY x) AS y3
		FROM xy ORDER BY x
)
, tridiagonal AS (
	SELECT *, 
			3*(y1-y0)/power(x1-x0, 2) AS d0,
			3*((y1-y0)/(power(x1-x0, 2)) + (y2-y1)/(power(x2-x1, 2))) AS d1, 
			3*((y2-y1)/(power(x2-x1, 2)) + (y3-y2)/(power(x3-x2, 2))) AS d2, 
			3*(y3-y2)/power(x3-x2, 2) AS d3, 
			1 / (x1-x0) AS a1, 
			1 / (x2-x1) AS a2, 
			1 / (x3-x2) AS a3, 
			2 / (x1-x0) AS b0, 
			2 * (1/(x1-x0) + 1/(x2-x1)) AS b1, 
			2 * (1/(x2-x1) + 1/(x3-x2)) AS b2, 
			2 / (x3-x2) AS b3, 
			1 / (x1-x0) AS c0, 
			1 / (x2-x1) AS c1, 
			1 / (x3-x2) AS c2 
		FROM fullxy ORDER BY x
)
, forward_sweep_1 AS (
	SELECT *
			, c0 / b0 as c_prime_0
			, c1 / (b1 - a1 * c0 / b0) as c_prime_1
			, c2 / (b2 - a2 * (c1 / (b1 - a1 * c0 / b0))) as c_prime_2
			, d0 / b0 as d_prime_0
			, (d1 - a1 * d0 / b0) / (b1 - a1 * c0 / b0) as d_prime_1
		FROM tridiagonal
)
, forward_sweep_2 AS (
	SELECT *
			, (d2 - a2 * d_prime_1) / (b2 - a2 * c_prime_1) as d_prime_2
			, (d3 - a3 * ((d2 - a2 * d_prime_1) / (b2 - a2 * c_prime_1)))
				/ (b3 - a3 * c_prime_2) as d_prime_3
		FROM forward_sweep_1
)
, backwards_substitution_1 AS (
	SELECT *
			, d_prime_3 as k3
			, d_prime_2 - c_prime_2 *(d_prime_3) as k2
			, d_prime_1 - c_prime_1 * (d_prime_2 - c_prime_2 *(d_prime_3)) as k1
	  FROM forward_sweep_2
)
, backwards_substitution_2 AS (
	SELECT *, d_prime_0 - c_prime_0 * k1 as k0
		FROM backwards_substitution_1
)
, coefficients AS (
	SELECT 
			x, y, x0, y0, x1, y1, x2, y2, k0, k1, k2, k3, 
			k1  * (x2-x1) - (y2-y1)  as a,
			-k2 * (x2-x1) + (y2-y1) as b
	  FROM backwards_substitution_2
)
, interpolated_table AS (
	SELECT *, (input_x - x1) / (x2 - x1) as t
		FROM x_coordinate, coefficients
			WHERE abs(coefficients.x1 - x_coordinate.previous_x) < 0.001
)
, final_table AS (
	SELECT *, (1-t) * y1 + t*y2 + t*(1-t)*(a*(1-t)+b*t) as output_y
		FROM interpolated_table 
		ORDER BY input_x
)

SELECT x, y, 
		ROUND(CAST(input_x AS DOUBLE PRECISION),2) AS input_x, 
		ROUND(CAST(output_y AS DOUBLE PRECISION),2) AS output_y, 
		CASE WHEN ABS(input_x - x) < 0.01 THEN y ELSE NULL END AS scatter_y 
	FROM final_table 
    ORDER BY x; 

DROP TABLE IF EXISTS xy; 