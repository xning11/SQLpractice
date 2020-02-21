import re 
import pandas as pd 


def extract_comments(filename):
    with open(filename,'r') as f:
        text = f.read() 
    regrex = re.compile(r'/\*(.|[\r\n])*?\*/') 
    comments = re.finditer(regrex, text) 
    questions = [] 
    for comment in comments: 
        question = re.sub(r'\*/','', re.sub(r'/\*', '', comment.group()).strip())
        questions.append(question)
    return questions 


if __name__ == '__main__': 
    questions = extract_comments('sakila-queries.sql') 
    print(questions)

    for i in range(len(questions)):
        questions[i] = questions[i].strip() 
    
    df = pd.DataFrame(questions, columns=['questions'])
    print(df) 