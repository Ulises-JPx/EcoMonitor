# EcoMonitor

**EcoMonitor** is an integrated environmental monitoring system that combines an embedded sensor unit with both web and mobile applications.  
It collects, stores, and visualizes environmental data for use in **research** and **precision agriculture**.

---

## Context

This project was developed for **Practice #3** of **Module 4: Hardware Integration for Data Science**,  
taught by **Professor David Higuera**, as part of the course:

**Advanced Artificial Intelligence for Data Science I (Group 101)** — *Team 2*

---

## Project Overview

- **Embedded System**  
  A sensor node (ESP32 / Arduino-based) that captures signals such as temperature, humidity, CO₂, light (LDR), and air quality (MQ135).  
  Data is timestamped and transmitted to a central sink (Google Sheets API or local CSV).

- **Backend**  
  Lightweight **Flask API** that ingests sensor data from Google Sheets (or CSV fallback) and exposes endpoints for querying devices and historical readings.

- **Frontend**  
  **Flutter application** for visualization, device discovery, and basic management.  
  Compatible with **mobile** and **web** platforms.

---

## Team — *Team 2*

- Ulises Jaramillo Portilla — *A01798380* — [GitHub Profile](https://github.com/Ulises-JPx)  
- Jesús Ángel Guzmán Ortega — *A01799257* — [GitHub Profile](https://github.com/JesusAGO24)  
- Sebastian Espinoza Farías — *A01750311* — [GitHub Profile](https://github.com/Sebastian-Espinoza-25)  
- Santiago Villazón Ponce de León — *A01746396* — [GitHub Profile](https://github.com/SantiagoVilla09)  
- Luis Ubaldo Balderas Sanchez — *A01751150* — [GitHub Profile](https://github.com/Luiss1715)  
- José Antonio Moreno Tahuilán — *A01747922* — [GitHub Profile](https://github.com/pepemt)  

---

## Quick Start

1. **Backend**  
   - See [`Backend/README.md`](Backend/README.md) for setup.  
   - Run with:  
     ```bash
     python src/app.py
     ```  
     or use the provided **Dockerfile**.

2. **Frontend**  
   - Navigate to `Frontend/`  
   - Install dependencies and run:  
     ```bash
     flutter pub get
     flutter run
     ```  
   - For Android emulators, use `10.0.2.2` as the backend host.

---

## Embedded System

The embedded component is built on an **ESP32** (Arduino-compatible).  
It reads multiple analog and digital sensors:

- Temperature  
- Humidity  
- CO₂  
- Light (LDR)  
- Air Quality (MQ135)

Each reading is formatted with an **ISO timestamp** and **device identifier**, then uploaded to:  
- A **cloud-accessible CSV** (Google Sheets export), or  
- Directly to the **Backend API**  

Designed for **low-power field deployment** and seamless integration into the ingestion pipeline.

---

## Documentation

- **Backend Guide** → installation, configuration, API reference, Docker usage  
- **Frontend Guide** → Flutter setup, run/build instructions  

See the corresponding `README.md` files inside each folder.

---

## License

This project is distributed under the terms of the license found in [`LICENSE`](LICENSE).

---

✨ For troubleshooting, development tips, and extended documentation, refer to the **Backend** and **Frontend** READMEs.
