create database bank_data;
use bank_data ;
CREATE TABLE finance_1 (
  id INT,
  member_id INT,
  loan_amnt DECIMAL(10,2),
  funded_amnt DECIMAL(10,2),
  funded_amnt_inv DECIMAL(10,2),
  term VARCHAR(10),
  int_rate DECIMAL(5,2),
  installment DECIMAL(10,2),
  grade CHAR(1),
  sub_grade VARCHAR(2),
  emp_title VARCHAR(100),
  emp_length VARCHAR(20),
  home_ownership VARCHAR(20),
  annual_inc DECIMAL(10,2),
  verification_status VARCHAR(20),
  issue_d DATE,
  loan_status VARCHAR(20),
  pymnt_plan CHAR(1),
  `desc` TEXT,
  purpose VARCHAR(50),
  title VARCHAR(100),
  zip_code CHAR(5),
  addr_state CHAR(2),
  dti DECIMAL(5,2)
);
CREATE TABLE finance_2 (
  id INT,
  delinq_2yrs INT,
  earliest_cr_line DATE,
  inq_last_6mths INT,
  mths_since_last_delinq INT,
  mths_since_last_record INT,
  open_acc INT,
  pub_rec INT,
  revol_bal INT,
  revol_util VARCHAR(10),
  total_acc INT,
  initial_list_status CHAR(1),
  out_prncp DECIMAL(10, 2),
  out_prncp_inv DECIMAL(10, 2),
  total_pymnt DECIMAL(10, 2),
  total_pymnt_inv DECIMAL(10, 2),
  total_rec_prncp DECIMAL(10, 2),
  total_rec_int DECIMAL(10, 2),
  total_rec_late_fee DECIMAL(10, 2),
  recoveries DECIMAL(10, 2),
  collection_recovery_fee DECIMAL(10, 2),
  last_pymnt_d DATE,
  last_pymnt_amnt DECIMAL(10, 2),
  next_pymnt_d DATE,
  last_credit_pull_d DATE
);

-- KPI-1(Year wise loan amount Stats)

SELECT YEAR(issue_d) AS loan_year,
       COUNT(*) AS total_loans,
       MIN(loan_amnt) AS min_loan_amount,
       MAX(loan_amnt) AS max_loan_amount,
       AVG(loan_amnt) AS avg_loan_amount,
       concat(format(SUM(loan_amnt)/100000,0),"L") AS total_loan_amount_in_lakhs
FROM finance_1
GROUP BY YEAR(issue_d)  order by SUM(loan_amnt) desc;


-- KPI-2 (Grade and sub grade wise revol_bal)

select F1.grade as grade_cte ,F1.sub_grade as subgrade_cte,sum(F2.revol_bal) as total_revol_bal,
  ROW_NUMBER() OVER(PARTITION BY grade ORDER BY SUM(F2.revol_bal) 
  ) AS RowNo from finance_1 F1 
inner join 
finance_2 F2 
on F1.id = F2.id 
group by  F1.grade ,F1.sub_grade 
order by grade,3 desc ;

-- KPI-2 (Grade and sub grade wise revol_bal in more detail)
with cte as 
(select F1.grade as grade_cte ,F1.sub_grade as subgrade_cte,sum(F2.revol_bal) as total_revol_bal,
  ROW_NUMBER() OVER(PARTITION BY grade ORDER BY SUM(F2.revol_bal) 
  ) AS RowNo from finance_1 F1 
inner join 
finance_2 F2 
on F1.id = F2.id 
group by  F1.grade ,F1.sub_grade 
order by grade,3 desc)
select * from cte where Rowno > 4;

-- KPI -3 (Total Payment for Verified Status Vs Total Payment for Non Verified Status)

select F1.verification_status,COUNT(*) AS number_of_status, 
AVG(F2.total_pymnt) AS avg_total_pymnt,
sum(F2.total_pymnt) as Total_paymnet 
from finance_1 F1 
inner join
finance_2 F2
on F1.id =F2.id 
where not F1.verification_status = "source Verified" 
group by F1.verification_status ;
       
-- KPI-4 (State wise and last_credit_pull_d wise loan status)
select F1.addr_state,year(F2.last_credit_pull_d),F1.loan_status 
from finance_1 F1 
inner join 
finance_2 F2
on F1.id =F2.id order by F1.addr_state ,F2.last_credit_pull_d desc , 3 asc;

-- KPI-4(State wise and last_credit_pull_d wise loan status in more detail)
WITH cte AS (
    SELECT
        F1.addr_state AS state,
        YEAR(F2.last_credit_pull_d) AS years,
        F1.loan_status AS loan_status,
        COUNT(*) AS count
    FROM
        finance_1 F1
        INNER JOIN finance_2 F2 ON F1.id = F2.id
    GROUP BY
        F1.addr_state,
        YEAR(F2.last_credit_pull_d),
        F1.loan_status
    ORDER BY
        F1.addr_state,
        COUNT(*) DESC
)
SELECT
    cte.state,
     cte.years AS year_max_count,
    MAX(cte.count) AS max_count,
   cte.loan_status
FROM
    cte
GROUP BY
    cte.state,
    cte.years,cte.loan_status
ORDER BY
    1,2 desc,3 desc,4 asc ;


-- kpi-5
select F1.home_ownership,count(last_pymnt_d) as num_of_lastpaymnt
from finance_1 F1
inner join 
finance_2 F2
on F1.id = F2.id group by F1.home_ownership 
order by num_of_lastpaymnt desc;



