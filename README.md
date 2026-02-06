# dbt-airalo Case Study
📚 dbt project to transform and generate semantic layer focused on customer acquisition metrics.

## Please write a short response covering:
#### How you approached the data modeling problem?
In order to solve the problem, first thing I did was create a project in BQ load and load the files to start quering the data. At first, I looked into duplicated rows, but also nulls on primary keys. I also explored the data with distinct to understand what values were being recorded for status, contry, etc. 

Once I got the idea of the data information and quality, I decided to model the data into a 
dbt dimensional model with marts. 

The decision was made based on the exercice, here the main focus was user behaviour and I modeled the tables in order to create a semantic layer baser on a mart user.

For that I used:
- staging to do basic cleaning
- intermediate to leverage heavy transformations and joins
- marts to allow easy access data based on entity models with the idea of building a semantic layer that non-technical users could easily query with external tools

I tried to develop the dbt project with the idea of how it's good practice to do it according to the source nature. 

For example: fact_orders as an accumulative fact, dim_user as a SCD2, and fact_exchange_rate as period snpashot fact.

So that we would have the most information about users and also the most accurate revenue numbers. 

#### Key assumptions you made about the data
I build snapshots for exchante_rates and assumed that the first rate in the table was the current rate to calculate usd and gbp amounts. 

#### Any data quality issues you encountered and how you handled them
I found out that fact_order had duplicates. So I deduped the rows in the intermediate layer and created completed_at, failed_at, refunded_at so it would be easier to spot purchase processes.

Also the ISO country codes were not uniform so I cast the codes, and homogeinise the primary keys so when doing joins I wouudn't have to cast them everytime. 

#### How do you decide where to perform
To decide how to perform, I thought that an analysis based on the nber of users, amount they spend, type of user (frequent, rare, etc.) grouped by the acquisition channel would help identify who are the users, and what's their purchase behaviour. 

Then according to the information I could see what channels are the most efficients and take decisions based on that.
