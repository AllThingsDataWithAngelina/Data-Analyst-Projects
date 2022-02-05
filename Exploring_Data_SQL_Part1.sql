--1---
---Summary of All PPP Approved Lending
--Note, there is also servicing Lender
Select count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Total_Net_Dollars, AVG(InitialApprovalAmount) Average_Loan_Size, 
(select count(distinct (OriginatingLender))from [dbo].[sba_public_data])Total_Originating_Lender_Count
from [dbo].[sba_public_data]
order by 3 desc

---Summary of 2021 PPP Approved Lending
Select count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Total_Net_Dollars, AVG(InitialApprovalAmount) Average_Loan_Size, 
(select count(distinct (OriginatingLender))from [dbo].[sba_public_data] where year(DateApproved) = 2021)Total_Originating_Lender_Count
from [dbo].[sba_public_data]
where year(DateApproved) = 2021
order by 3 desc

---Summary of 2020 PPP Approved Lending
Select count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Total_Net_Dollars, AVG(InitialApprovalAmount) Average_Loan_Size, 
(select count(distinct (OriginatingLender))from [dbo].[sba_public_data] where year(DateApproved) = 2020)Total_Originating_Lender_Count
from [dbo].[sba_public_data]
where year(DateApproved) = 2020
order by 3 desc


---2---
---Summary of 2021 PPP Approved Loans per Originating Lender, loan count, total amount and average
--Top 15 Originating Lenders for 2021 PPP Loans
--Data is ordered by Net_Dollars
Select top 15 OriginatingLender, count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Net_Dollars, AVG(InitialApprovalAmount) Average_Loan_Size
from [dbo].[sba_public_data]
where year(DateApproved) = 2021
group by OriginatingLender
order by 3 desc

Select top 15 OriginatingLender, count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Net_Dollars, AVG(InitialApprovalAmount) Average_Loan_Size
from [dbo].[sba_public_data]
where year(DateApproved) = 2020
group by OriginatingLender
order by 3 desc


---3----
---Top 20 Industries that received the PPP Loans in 2021
-- I need to add the NAICS codes to the GitHub Repo, extracted from SQL
with cte as (

	select ncd.Sector, count(LoanNumber) as Loans_Approved, sum(CurrentApprovalAmount) Net_Dollars
	from [dbo].[sba_public_data] main
	inner join [dbo].[sba_naics_sector_codes_description]  ncd
		on left(cast(main.NAICSCode as varchar), 2) = ncd.LookupCode
	where year(DateApproved) = 2021 
	group by ncd.Sector
	--order by 3 desc

)
SELECT 
	sector,Loans_Approved,
	SUM(Net_Dollars) OVER(PARTITION BY sector) AS Net_Dollars,
	--SUM(Net_Dollars) OVER() AS Total,
	CAST(1. * Net_Dollars / SUM(Net_Dollars) OVER() AS DECIMAL(5,2)) * 100 AS "Percent by Amount"  
FROM cte  
order by 3 desc
--where year(DateApproved) = 2021 

---4---
--States and Territories
select BorrowerState as state, count(LoanNumber) as Loan_Count, sum(CurrentApprovalAmount) Net_Dollars
from [dbo].[sba_public_data] main
--where cast(DateApproved as date) < '2021-06-01'
group by BorrowerState
order by 1


---5----
---Demographics for PPP
select race, count(LoanNumber) as Loan_Count, sum(CurrentApprovalAmount) Net_Dollars
from [dbo].[sba_public_data]
group by race
order by 3

select gender, count(LoanNumber) as Loan_Count, sum(CurrentApprovalAmount) Net_Dollars
from [dbo].[sba_public_data]
group by gender
order by 3

select Ethnicity, count(LoanNumber) as Loan_Count, sum(CurrentApprovalAmount) Net_Dollars
from [dbo].[sba_public_data]
group by Ethnicity
order by 3

select Veteran, count(LoanNumber) as Loan_Count, sum(CurrentApprovalAmount) Net_Dollars
from [dbo].[sba_public_data]
group by Veteran
order by 3

---6---
---How much of the PPP Loans of 2021 have been fully forgiven
select count(LoanNumber) as Count_of_Payments,  sum(ForgivenessAmount) Forgiveness_amount_paid
from sba_public_data
where year(DateApproved) = 2020 and ForgivenessAmount <> 0

---Summary of 2021 PPP Approved Lending
Select count(LoanNumber) as Loans_Approved, sum(InitialApprovalAmount) Total_Net_Dollars, sum(ForgivenessAmount) Forgiveness_amount_paid,
(select count(distinct (OriginatingLender))from [dbo].[sba_public_data] where year(DateApproved) = 2021)Total_Originating_Lender_Count
from [dbo].[sba_public_data]
where year(DateApproved) = 2020 
order by 3 desc


--7---
--In which month was the highest amount given out by the SBA to borrowers
select Year(DateApproved) Year_Approved, Month(DateApproved)Month_Approved, ProcessingMethod, sum(CurrentApprovalAmount) Net_Dollars
from sba_public_data
group by Year(DateApproved),  Month(DateApproved), ProcessingMethod
order by 4 desc