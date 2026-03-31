# 🚀 Real-Time User Activity Data Pipeline

## 📌 Problem Statement

Modern applications generate high-velocity user activity data (clicks, events, logs) that must be processed in real time for analytics and decision-making.

This project simulates a **production-grade real-time data pipeline** that ingests, streams, processes, and stores user data with high scalability and fault tolerance.

---

## 🏗️ Architecture Overview

This system is built using a distributed, event-driven architecture:

* **Data Source:** Simulated user events via API
* **Orchestration:** Apache Airflow for scheduling workflows
* **Streaming:** Apache Kafka for real-time data ingestion
* **Processing:** Apache Spark (PySpark) for distributed transformations
* **Storage:** Cassandra (NoSQL) + PostgreSQL (staging)
* **Containerization:** Docker

---

## 🔄 Data Flow

1. Airflow extracts user data from API
2. Data stored in PostgreSQL (staging layer)
3. Kafka streams data to downstream systems
4. Spark processes and transforms data
5. Processed data stored in Cassandra

---

## ⚙️ Key Engineering Decisions

* **Kafka** → Enables decoupled, scalable streaming
* **Spark** → Distributed processing for large datasets
* **Cassandra** → High write throughput & scalability
* **PostgreSQL** → Structured staging layer

---

## ⚡ Scalability & Performance

* Kafka partitions enable horizontal scaling
* Spark processes data in parallel
* Cassandra ensures high availability

---

## 🛠️ Challenges Solved

* Handling real-time streaming + batch ingestion
* Ensuring data consistency across systems
* Managing distributed components via Docker

---

## 📊 What This Project Demonstrates

* Real-time streaming pipelines
* Distributed data processing
* System design thinking
* End-to-end data engineering
