# dbt-airalo Case Study
📚 dbt project to transform and generate semantic layer focused on customer acquisition metrics.

## Please write a short response covering:
#### How you approached the data modeling problem?
Once I had the data in BQ, I looked into duplicated rows, but also nulls on primary keys. I also explored the data with distinct to understand what values were being recorded for status, country, etc. 

Once I got the idea of the data information and quality, I decided to model the data into a dbt dimensional model with marts. 

The decision was made based on the exercise, here the main focus was user behavior and I modeled the tables in order to create a semantic layer based on a user mart.

For that I used:
- staging to do basic cleaning
- intermediate to leverage heavy transformations and joins
- marts to allow easy access data based on entity models with the idea of building a semantic layer that non-technical users could easily query with external tools

I tried to develop the dbt project with the idea of how it's good practice to do it according to the source nature. 

For example: fct_order as an accumulating fact, dim_user as a SCD2, and fct_exchange_rate as a periodic snapshot fact.

So that we would have the most information about users and also the most accurate revenue numbers. 

#### Key assumptions you made about the data
For exchange_rates and assumed that the first rate in the table was the current rate to calculate usd and gbp amounts. 
For fct_orders I assumed that if a user placed an order in the morning and another one in the afternoon, that the secound order would apear on the next day. 

#### Any data quality issues you encountered and how you handled them
I found out that fct_order had duplicates. So I deduped the rows in the intermediate layer and created completed_at, failed_at, refunded_at so it would be easier to spot purchase processes.

Also the ISO country codes were not uniform so I cast the codes, and standardized the primary keys so when doing joins I wouldn't have to cast them every time. 

#### How did you decide what to analyze
To decide what to analyze to answer the question about marketing focus, I thought that an analysis based on user purchase behaviour would be the key. So I created a user mart with metrics like:
    - nber of new users
    - nber of returned users
    - average amount spent by new users
    - average amount spent by returned users
    - average time in days for a user to return
 
Here's a query example:

```SQL
select 
  
  sum(is_new) as new_users, 
  round(sum(gbp_amount_spent_new), 2) as total_amount_spend_new, 
  round(sum(gbp_amount_spent_new) / sum(is_new), 2) as avg_amount_spent_new, 
  
  sum(has_returned) as returned_users, 
  sum(gbp_amount_spent_returned) as total_amount_spend_returned, 
  round(sum(gbp_amount_spent_returned) / sum(has_returned), 2) as avg_amount_spent_returned, 

  avg(days_between_first_and_last_purchase) avg_days_between_first_and_last_purchase
from `mart.user` 
```
The results of this query show that the amount spent by new returned users is 3.8 times higher than the amount spent by new users, and that on average a user returns after 55 days. Concluding that it might be a good option to invest on re-engagement.

To have more information on where to focus, I decided to add dimensions like country. 


