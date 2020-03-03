# List of interesting posts using SQL

## Calculating significance of A/B tests in Redshift [link](https://www.sisense.com/blog/ab-testing-in-redshift/)

```sql
create or replace function 
    significance(control_size integer, 
               control_conversion integer, 
               experiment_size integer, 
               experiment_conversion integer)
    returns float
    stable as $$
        from scipy.stats import norm

        def standard_error(sample_size, successes):
            p = float(successes) / sample_size
            return ((p * (1 - p)) / sample_size) ** 0.5

        def zscore(size_a, successes_a, size_b, successes_b):
            p_a = float(successes_a) / size_a
            p_b = float(successes_b) / size_b
            se_a = standard_error(size_a, successes_a)
            se_b = standard_error(size_b, successes_b)
            numerator = (p_b - p_a)
            denominator = (se_a ** 2 + se_b ** 2) ** 0.5
            return numerator / denominator
    
        def percentage_from_zscore(zscore):
            return norm.sf(abs(zscore))
        
        exp_zscore = zscore(control_size, control_conversion, 
                            experiment_size, experiment_conversion)
        return percentage_from_zscore(exp_zscore)
    $$ language plpythonu;
```

```sql
select
    'first_experiment' as name, 
    significance(1000, 100, 1000, 125)
union
select
    'second_experiment' as name, 
    significance(500, 30, 500, 38)
```

## Measuring AB Tests: SQL for p-value graphs in Redshift [link](https://engineering.ezcater.com/measuring-ab-tests-sql-for-pvalue-graphs-in-redshift)

```sql
WITH first_exposures AS (
    SELECT
        tracking_id,
        created_at,
        event,
        experiment_test,
        experiment_result,
        date_trunc('day', created_at) AS day
    FROM warehouse.events
    WHERE category = 'experiment'
        AND created_at > '10-13-16'
),
conversions_order_placed_1 AS (
    SELECT
        tracking_id,
        created_at
    FROM warehouse.events
    WHERE event_name = 'Order: order-placed-1'
    GROUP BY 1, 2
),
results AS (
    SELECT
        event,
        experiment_test,
        experiment_result,
        day,
        count(DISTINCT first_exposures.tracking_id)            exposures,
        count(DISTINCT conversions_order_placed_1.tracking_id) order_placed_1,
        count(DISTINCT conversions_order_placed_1.tracking_id) /
        count(DISTINCT first_exposures.tracking_id) :: FLOAT   conversion_rate
    FROM first_exposures
    LEFT JOIN conversions_order_placed_1
        ON first_exposures.tracking_id = conversions_order_placed_1.tracking_id 
            AND conversions_order_placed_1.created_at > first_exposures.created_at
    GROUP BY 1, 2, 3, 4
    ORDER BY 1, 2, 3, 4
),
cumulative AS (
    SELECT
        DAY,
        experiment_test,
        experiment_result,
        exposures,
        sum(exposures)
            OVER (
            PARTITION BY experiment_test, experiment_result
            ORDER BY DAY
            ROWS UNBOUNDED PRECEDING ) cumulative_exposures,
        order_placed_1,
        sum(order_placed_1)
            OVER (
            PARTITION BY experiment_test, experiment_result
            ORDER BY DAY
            ROWS UNBOUNDED PRECEDING ) cumulative_order_placed_1
    FROM results
    ORDER BY experiment_test, experiment_result, DAY
),
daily_experiments AS (
    SELECT
        experiment_arm.day,
        experiment_arm.experiment_test,
        experiment_arm.cumulative_exposures :: INT      experiment_cumulative_exposures,
        experiment_arm.cumulative_order_placed_1 :: INT experiment_cumulative_conversions,
        control_arm.cumulative_exposures :: INT         control_cumulative_exposures,
        control_arm.cumulative_order_placed_1 :: INT    control_cumulative_conversions
    FROM cumulative experiment_arm
        JOIN cumulative AS control_arm ON experiment_arm.day = control_arm.day
    WHERE
        experiment_arm.experiment_test = control_arm.experiment_test
        AND experiment_arm.experiment_result <> 'control'
        AND control_arm.experiment_result = 'control'
)
SELECT *, 
    significance(control_cumulative_exposures, 
    control_cumulative_conversions, 
    experiment_cumulative_exposures, 
    experiment_cumulative_conversions)
FROM daily_experiments
WHERE experiment_test = 'ez97';
```

## Confidence Intervals in SQL [link](https://calogica.com/sql/2018/05/09/confidence-intervals-sql.html)

```sql
-- We'll first aggregate our order and exchange data to a weekly level
with exchange_rate as (
    select
        f.week,
        sum(f.orders) as orders,
        sum(f.exchanges) as exchanges,
        sum(f.exchanges)::float/sum(f.orders) as exchange_rate
    from
        my_order_and_exchanges_table f
    group by 1
),
-- then we compute the implied error for each week
exchange_rate_error as (
    select
        e.*,
        -- Normal approximation to Beta distribution standard deviation, see:
        -- https://en.wikipedia.org/wiki/Binomial_proportion_confidence_interval
        -- sqrt( p * (1 - p) / n )
        sqrt(e.exchange_rate * (1 - e.exchange_rate)/e.orders) as exchange_rate_se
    from
        exchange_rate e
),
-- as an extension, we'll add a table of z-scores
-- for different confidence intervals we may want to compute
z_values as (
    select  1.65 as z_value, '90% CI' as z_value_name
    union all
    select  1.96 as z_value, '95% CI' as z_value_name
)
-- We then apply each z-value to the implied error and subtract/add it
-- from the exchange rate to get a lower/upper bound
select
    z.z_value_name,
    s.*,
    -- lower bound at 0
    greatest(
        s.exchange_rate - z.z_value * s.exchange_rate_se
    , 0) as exchange_rate_lb,
    s.exchange_rate + z.z_value * s.exchange_rate_se as exchange_rate_ub
from
    exchange_rate_error s,
    z_values z
order by
    z.z_value_name,
    s.week;
```

## Find user sessions [link](https://czep.net/16/session-ids-sql.html) [link](https://mode.com/blog/finding-user-sessions-sql)

```sql
lagged_events as (
    select
        user_id,
        event_time,
        lag(event_time) over (partition by date(event_time), user_id order by event_time) as prev
    from
        db_events
),
new_sessions as (
    select
        user_id,
        event_time,
        case
            when prev is null then 1
            when event_time - prev > interval '30 minutes' then 1
            else 0
        end as is_new_session
    from
        lagged_events
),
session_index as (
    select
        user_id,
        event_time,
        is_new_session,
        sum(is_new_session) over (partition by user_id order by event_time rows between unbounded preceding and current row) as session_index
    from
        new_sessions
)
select
    cast(user_id as varchar) || '.' || cast(session_index as varchar) as session_id,
    user_id,
    event_time,
    is_new_session,
    session_index
from
    session_index
order by 
    user_id, event_time
```