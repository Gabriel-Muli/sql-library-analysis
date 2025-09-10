import pandas as pd
df=pd.read_csv('books.csv')
print('books: ',df.isnull().values.any())# checking for any null values in books.csv
print(df.index[-1]) # to show the last index of the rows
print('The max length of items in the "isbn" column is: ',df['isbn'].astype(str).str.len().max())
print('The max length of items in the "book_title" column is: ',df['book_title'].astype(str).str.len().max())
print('The max length of items in the "category" column is: ',df['category'].astype(str).str.len().max())
print('The max length of items in the "rental_price" column is: ',df['rental_price'].astype(str).str.len().max())
print('The max length of items in the "statu_s" column is: ',df['statu_s'].astype(str).str.len().max())
print('The max length of items in the "author" column is: ',df['author'].astype(str).str.len().max())
print('The max length of items in the "publisher" column is: ',df['publisher'].astype(str).str.len().max())
print('\n')


df=pd.read_csv('branch.csv')
print('branch: ',df.isnull().values.any())# checking for any null values in branch.csv
print('The max length of items in the "branch_id" column is: ',df['branch_id'].map(len).max())
print('The max length of items in the "manager_id" column  is: ',df['manager_id'].map(len).max())
print('The max length of items in the "branch_address" column  is: ',df['branch_address'].map(len).max())
print('The max length of items in the "contact_no" column is: ',df['contact_no'].astype(str).str.len().max())
print('\n')

df=pd.read_csv('employees.csv')
print('employees: ',df.isnull().values.any())# checking for any null values in employees.csv
print('The max length of items in the "emp_id" is: ',df['emp_id'].map(len).max())
print('The max length of items in the "emp_name" is: ',df['emp_name'].map(len).max())
print('The max length of items in the "positio_n" is: ',df['positio_n'].map(len).max())
print('The max length of items in the "salary" is: ',df['salary'].astype(str).str.len().max())
print('The max length of items in the "branch_id" is: ',df['branch_id'].map(len).max())
print('\n')

df=pd.read_csv('issued_status.csv')
df['issued_date']=pd.to_datetime(df['issued_date'])
df['issued_date']=df['issued_date'].dt.strftime('%Y-%m-%d')
print('issued_status: ',df.isnull().values.any())# checking for any null values in issued_status.csv
print("The max length of items in the 'issued_id' column is: ",df['issued_id'].map(len).max())
print("The max length of items in the 'issued_member_id' column is: ",df['issued_member_id'].map(len).max())
print("The max length of items in the 'issued_book_name' column is: ",df['issued_book_name'].map(len).max())
print("The max length of items in the 'issued_book_isbn' column is: ",df['issued_book_isbn'].map(len).max())
print("The max length of items in the 'issued_emp_id' column is: ",df['issued_emp_id'].map(len).max())
df.to_csv('issued_status_formatted.csv',index=False)
print('\n')

df=pd.read_csv('members.csv')
df['reg_date']=pd.to_datetime(df['reg_date'])
df['reg_date']=df['reg_date'].dt.strftime('%Y-%m-%d')
print('members: ',df.isnull().values.any())# checking for any null values in members.csv
print('The max length of items in the "member_id" is: ',df['member_id'].map(len).max())
print('The max length of items in the "member_name" is: ',df['member_name'].map(len).max())
print('The max length of items in the "member_address" is: ',df['member_address'].map(len).max())
df.to_csv('members_formatted.csv',index=False)
print('\n')

q=pd.read_csv('return_status.csv')
q['return_date']=pd.to_datetime(q['return_date'],errors='coerce') #This is to converts the return_date column into datetime,invalid values become NaT
q['return_date']=q['return_date'].dt.strftime('%Y-%m-%d')#Format the column as 'YYYY-MM-DD' strings for MySQL import
print('return_status: ',q.isnull().values.any())# This will return true because the string 'NULL' is parsed as missing by pandas
print('The last index in this table is: ',q.index[-1]) # to show the last index of the rows
print("The max length of item in the 'return_id' column is: ", q['return_id'].map(len).max())
print("The max length of item in the 'issued_id' column is: ", q['issued_id'].map(len).max())
q['return_book_name']='NULL'
q['return_book_isbn']='NULL'
q.to_csv('return_status_formatted.csv',index=False)



