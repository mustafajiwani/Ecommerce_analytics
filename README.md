# E-commerce Customer Analytics Project: Insights on Behavior, Churn, and Product Trends

This end-to-end data analytics project focuses on understanding customer behavior, product performance, and time-based order trends for an e-commerce platform using Python, SQL, and Tableau. The analysis aims to provide actionable insights to optimize marketing, sales strategies, and product offerings.

## Data Description

The dataset used for this project includes customer order data, product details, and departmental information. It was provided as a CSV file, which was processed, cleaned, and analyzed. The dataset contains information on customer demographics, product categories, and order history.

## 📊 Tools Used

- **Python**: For data cleaning, exploratory data analysis (EDA), and machine learning (scikit-learn, pandas, seaborn, matplotlib).
- **SQL (MySQL)**: For querying and analyzing large datasets, including joins, aggregations, and window functions.
- **Tableau**: For creating interactive visualizations and dashboards.

## 📁 Project Structure

- `Ecommerce.sql` – All SQL queries used for analysis
- `Ecommerce Analysis.py` – Python code for EDA and ML
- `Ecommerce dataset Portfolio.twbx` – Tableau workbook with all dashboards
- `dashboard_screenshots` – PNG snapshots of the Tableau dashboards
- `pythonplots` - PNG snapshots of the python visualizations (ROC curve, elbow method, correlation heatmap)

## 🚀 Project Overview

- Used SQL to run over 20 queries to gain behavioral insights such as reorder trends, cart size, time-based purchase patterns, and churn risk
- Performed data cleaning, exploratory data analysis (EDA), and machine learning (reorder prediction) using Python
- Created 5 interactive Tableau dashboards based on the analysis to visualize customer behavior, product trends, and time-based order patterns
  
## 🧠 Skills Used

- SQL: Joins, CTEs, window functions, aggregations
- Python: Pandas (data manipulation), seaborn & matplotlib (visualizations), scikit-learn (machine learning models)
- Tableau: Charts, filters, calculated fields, dashboard design

## 🔍 Key Insights

- **Churn Prediction**: Identified high-risk churn users based on extended order gaps and infrequent purchases.
- **Customer Segmentation**: Segmented customers into key groups based on order frequency using clustering techniques (e.g., k-means).
- **Cross-Sell Opportunities**: Revealed popular product pairs that could be marketed together to increase sales.
- **Time-of-Day & Day-of-Week Trends**: Identified optimal times for targeted marketing campaigns, aligning with customer activity patterns.
- **Departmental Strategy**: Highlighted departments with low reorder rates, suggesting areas for product strategy improvement.
- **First vs. Repeat Purchase Behavior**: Gained insights into how first-time and repeat buyers behave differently, helping to optimize marketing efforts.

## Python Analysis and Visualizations

- **ROC Curve**:Evaluated the performance of the machine learning model used for churn prediction. A higher area under the curve (AUC) indicates better model performance
- **Elbow Method**: Used to determine the optimal number of clusters for customer segmentation, helping to define meaningful customer groups
- **Correlation Heatmap**: Showed correlations between various product and customer features, identifying key factors that influence purchasing behavior
  
These plots can be found in the `pythonplots` folder in this repository.
  
## 📈 Dashboards

View full Tableau dashboards here:  
👉 [Tableau Public Workbook] (https://public.tableau.com/app/profile/mustafa.jiwani/viz/E-CommerceCustomerBehaviorAnalysis/UserBehavior)

Dashboard topics:
- **User Behavior & Lifecycle**
- **Product Insights**
- **Department Trends**
- **Time-Based Order Patterns**

## 📌 Author

Mustafa Jiwani – Data Analyst  
📫 [Connect with me on LinkedIn] (www.linkedin.com/in/mustamahemud-448318230)
