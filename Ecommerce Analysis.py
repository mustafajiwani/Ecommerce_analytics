#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr 24 14:26:36 2025

@author: mustafajiwani
"""
import numpy as np
import pandas as pd
dataset=pd.read_csv("ECommerce_consumer behaviour.csv")
dataset.columns
dataset.info()
dataset.isnull().sum()
dataset["days_since_prior_order"]=dataset["days_since_prior_order"].fillna(0).astype(int)
dataset.duplicated().sum()
dow_map = {
    0: 'Sunday', 1: 'Monday', 2: 'Tuesday', 3: 'Wednesday',
    4: 'Thursday', 5: 'Friday', 6: 'Saturday'
}
dataset['order_dow_name'] = dataset['order_dow'].map(dow_map)
dataset['order_dow_name']
dataset['time_of_day'] = pd.cut(dataset['order_hour_of_day'],
                                bins=[0, 6, 12, 18, 24],
                                labels=['Night', 'Morning', 'Afternoon', 'Evening'],
                                right=False)
dataset.info()
unique_products=dataset['product_name'].unique()
product_prices = {product: round(np.random.uniform(1, 30), 2) for product in unique_products}
dataset['price'] = dataset['product_name'].map(product_prices)
dataset[['product_name', 'price']].head()
dataset['revenue'] = dataset['price']
dataset.columns
print("Unique users:", dataset['user_id'].nunique())
print("Unique products:", dataset['product_name'].nunique())
print("Total Orders:", dataset['order_id'].nunique())
print("Average days between orders:", dataset['days_since_prior_order'].astype(float).mean())
products_per_order=dataset.groupby("order_id")['product_name'].count().mean()
print(f"Average number of products per order: {products_per_order:.2f}")
reorder_rate=dataset['reordered'].mean()
print(f"Reorder Rate: {reorder_rate:.2%}")

import matplotlib.pyplot as plt
import seaborn as sns

sns.set_style('whitegrid')

plt.figure(figsize=(10,6))
sns.countplot(data=dataset, x='order_dow', palette='viridis', order=sorted(dataset['order_dow'].unique()))

plt.xlabel('Day of the Week (0=Sunday, 6=Saturday)', fontsize=12)
plt.ylabel('Number of Orders', fontsize=12)
plt.title('Orders by Day of the Week', fontsize=15)
plt.show()

plt.figure(figsize=(10,6))
sns.countplot(data=dataset, x='time_of_day', palette='coolwarm',
              order=['Morning', 'Afternoon', 'Evening', 'Night'])
plt.xlabel('Time of Day', fontsize=12)
plt.ylabel('Number of Orders', fontsize=12)
plt.title('Orders by Time of Day', fontsize=15)
plt.show()

top_10_products = dataset.groupby('product_name')['product_id'].count().sort_values(ascending=False).head(10)
plt.figure(figsize=(8,8))
plt.pie(top_10_products, labels=top_10_products.index, autopct='%1.1f%%', 
        colors=sns.color_palette('Set3', n_colors=10), startangle=90, wedgeprops={'edgecolor': 'black'})
plt.title('Top 10 Most Sold Products (Pie Chart)', fontsize=15)
plt.show()

department_order_counts = dataset['department'].value_counts()
plt.figure(figsize=(12,6))
department_order_counts.plot(kind='bar', color='skyblue')
plt.xlabel('Department', fontsize=12)
plt.ylabel('Number of Orders', fontsize=12)
plt.title('Most Popular Departments', fontsize=15)
plt.xticks(rotation=45, ha='right')
plt.show()

reorders_by_department = dataset.groupby('department')['reordered'].sum().sort_values(ascending=False)
plt.figure(figsize=(12,6))
reorders_by_department.plot(kind='bar', color='salmon')
plt.xlabel('Department', fontsize=12)
plt.ylabel('Number of Reorders', fontsize=12)
plt.title('Reorders by Department', fontsize=15)
plt.xticks(rotation=45, ha='right')  
plt.show()

plt.figure(figsize=(10, 6))
plt.hist(dataset['days_since_prior_order'], bins=30, color='skyblue', edgecolor='black')
plt.xlabel('Days Since Prior Order', fontsize=12)
plt.ylabel('Frequency', fontsize=12)
plt.title('Days Since Prior Order Distribution', fontsize=15)
plt.show()

correlation_matrix=dataset.corr()

plt.figure(figsize=(10,8))
sns.heatmap(correlation_matrix, annot=True, cmap="coolwarm", fmt='.2f', linewidth=0.5)
plt.title('Correlation Heatmap')
plt.show

top_customers=dataset.groupby('user_id')['order_id'].nunique().sort_values(ascending=False).reset_index()
top_customers=top_customers.rename(columns={'order_id':'num_orders'})
top_customers.head(10)

time_of_day_orders=dataset['time_of_day'].value_counts().reset_index()
time_of_day_orders.columns=['time_of_day','num_orders']
time_of_day_orders

from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score, confusion_matrix, classification_report

y=dataset['reordered']
X=dataset[['order_dow', 'order_hour_of_day', 'days_since_prior_order', 'department_id', 'add_to_cart_order']]

X_train, X_test, y_train, y_test= train_test_split(X, y, test_size=0.2, random_state=42)

logreg=LogisticRegression(max_iter=1000, class_weight='balanced')
logreg.fit(X_train, y_train)

y_pred_logreg=logreg.predict(X_test)

print("Logistic Regression Results:")
print("Accuracy:", accuracy_score(y_test, y_pred_logreg))
print("Confusion Matrix:\n", confusion_matrix(y_test, y_pred_logreg))
print("Classification Report:\n", classification_report(y_test, y_pred_logreg))

from sklearn.metrics import roc_curve, auc

y_prob=logreg.predict_proba(X_test)[:,1]
fpr,tpr, thresholds= roc_curve(y_test,y_prob)
roc_auc= auc(fpr,tpr)
plt.figure(figsize=(8, 6))
plt.plot(fpr, tpr, color='blue', label=f'ROC curve (AUC = {roc_auc:.2f})')
plt.plot([0, 1], [0, 1], color='gray', linestyle='--')  
plt.xlim([0.0, 1.0])
plt.ylim([0.0, 1.05])
plt.xlabel('False Positive Rate')
plt.ylabel('True Positive Rate')
plt.title('Receiver Operating Characteristic (ROC) Curve')
plt.legend(loc="lower right")
plt.show()

rf_model = RandomForestClassifier(class_weight='balanced', random_state=42)
rf_model.fit(X_train, y_train)

y_pred = rf_model.predict(X_test)

accuracy = accuracy_score(y_test, y_pred)
print(f"Accuracy: {accuracy}")
conf_matrix = confusion_matrix(y_test, y_pred)
print("Confusion Matrix:")
print(conf_matrix)
class_report = classification_report(y_test, y_pred)
print("Classification Report:")
print(class_report)

importances=rf_model.feature_importances_
feature_importances= pd.DataFrame({'feature': X.columns, 'importance': importances})
feature_importances=feature_importances.sort_values(by='importance', ascending=False)
print(feature_importances)

customer_summary=dataset.groupby('user_id').agg({
    'order_id': 'nunique',
    'days_since_prior_order': 'mean',
    'reordered': 'mean'
}).reset_index()

customer_summary.columns=['customer_id', 'num_orders', 'avg_days_between_orders', 'reorder_ratio']
print(customer_summary.head())

from sklearn.preprocessing import StandardScaler

features=customer_summary[['num_orders', 'avg_days_between_orders', 'reorder_ratio']]
scaler=StandardScaler()
scaled_features=scaler.fit_transform(features)

from sklearn.cluster import KMeans

inertia=[]
k_range=range(1,11)

for k in k_range:
    kmeans=KMeans(n_clusters=k, random_state=42)
    kmeans.fit(scaled_features)
    inertia.append(kmeans.inertia_)
    
plt.plot(k_range, inertia, marker='o')
plt.xlabel('Number of Clusters (k)')
plt.ylabel('Inertia')
plt.title('Elbow Method for Finding Optimal k')
plt.show()

kmeans=KMeans(n_clusters=4, random_state=42)
customer_summary['cluster']=kmeans.fit_predict(scaled_features)

print(customer_summary.head())

plt.figure(figsize=(8,6))
sns.scatterplot(
    data=customer_summary,
    x='num_orders',
    y='avg_days_between_orders',
    hue='cluster',
    palette='Set2'
)
plt.xlabel('Number of Orders')
plt.ylabel('Average Days Between Orders')
plt.title('Customer Segments')
plt.show()

from mpl_toolkits.mplot3d import Axes3D

fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection='3d')

ax.scatter(
    customer_summary['num_orders'], 
    customer_summary['avg_days_between_orders'], 
    customer_summary['reorder_ratio'], 
    c=customer_summary['cluster'], 
    cmap='rainbow', 
    alpha=0.7
)

ax.set_xlabel('Number of Orders')
ax.set_ylabel('Average Days Between Orders')
ax.set_zlabel('Reorder Ratio')
ax.set_title('3D Customer Segmentation')

plt.show()

customer_summary.groupby('cluster').mean()

pip install plotly

import plotly.express as px

fig = px.scatter_3d(
    customer_summary, 
    x='num_orders', 
    y='avg_days_between_orders', 
    z='reorder_ratio',
    color='cluster',
    title="3D Customer Segmentation (Interactive)"
)
fig.show()

import plotly.io as pio
pio.renderers.default = 'browser'

fig.show()

dataset.to_csv("ECommerce_enriched.csv", index=False)

dataset.count()









