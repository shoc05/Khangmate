# Khangmate 

Khangmate App is a Bhutan-focused house rental application that allows users to list rental houses with pinned map locations and helps renters discover available homes across Bhutan with an interactive map.

---

## Table of Contents

* [Overview](#overview)
* [Key Features](#key-features)
* [Tech Stack](#tech-stack)
* [Folder Structure](#folder-structure)
* [Installation](#installation)
* [Usage](#usage)
* [Feature Table](#feature-table)
* [Flow Diagrams](#flow-diagrams)
* [Legend](#legend)
* [Screenshots](#screenshots)
* [Contributing](#contributing)
* [License](#license)

---

## Overview

Khangmate simplifies house rentals in Bhutan. Renters can find nearby houses, communicate with property owners, and make bookings directly. Property owners can list houses, manage bookings, and respond to renter requests efficiently.  

Key advantages:  

* Interactive map-based discovery  
* Real-time chat and notifications  
* Booking management with approvals  

---

## Key Features

| Feature | Description |
|---------|-------------|
| House Listing | List houses with accurate location pins on the map |
| Map Discovery | Browse houses across Bhutan interactively |
| GPS Nearby Detection | Show houses close to the user automatically |
| In-app Chat | Communicate directly with owners |
| Booking Management | Send booking requests and receive approvals/rejections |
| Notifications | Get notified about booking updates |
| Supabase Backend | Handles authentication, database, and real-time messaging |

---

## Tech Stack

* **Frontend:** Flutter, React Native Web (optional for web)  
* **Backend:** Supabase (Auth, Database, Real-time messaging)  
* **Maps & Location:** Google Maps API / OpenStreetMap, GPS detection  
* **Database:** PostgreSQL (via Supabase)  

---

## Installation

### Prerequisites

* Flutter SDK (latest stable version)  
* Node.js (if using web)  
* Android Studio / Xcode for emulators  
* Supabase account  

### Steps

```bash
git clone https://github.com/shoc05/Khangmate.git
cd Khangmate
flutter pub get

Configure Supabase keys (SUPABASE_URL and SUPABASE_ANON_KEY)

Run the app: flutter run

For web: flutter run -d chrome

Usage

Sign up / log in via Supabase

Browse houses on the map or search by location

View house details (photos, description, owner info)

Chat and send booking requests

Owners can approve/reject requests and manage listings

Feature Table
User Type	Actions
Renter	Search houses, view details, chat, send booking requests
Owner	Add listings, approve/reject bookings, manage chats
Admin (optional)	Monitor activity, manage users/listings
Flow Diagrams
1. Map & House Discovery Flow
+----------------+       +-----------------------+       +-------------------+
|  User opens    |  GPS  | Detect nearby houses  |  Map  | Show houses on    |
|     app        +------>+     on map           +------>+     map           |
+----------------+       +-----------------------+       +-------------------+
                                      |
                                      v
                          +-------------------+
                          | Click house pin    |
                          +-------------------+
                                      |
                                      v
                          +-------------------+
                          | View house details |
                          | Photos, info, etc. |
                          +-------------------+
                                      |
                                      v
                          +-------------------+
                          | Chat / Send Booking|
                          +-------------------+

2. Chat & Booking Flow
Renter                        Owner
  |                             |
  |--- Send message/booking --->|
  |                             |
  |<--- Receive notification ---|
  |                             |
  |--- Receive status update -->|
  |                             |

Legend
Map Pin / Status	Color / Symbol
Available House	🟢 Green
Occupied House	🔴 Red
Booking Pending	🟡 Yellow
Illegal Zone (if any)	⚠️ Orange
Screenshots (ASCII-style preview)

Home Screen:

+------------------------------------------+
|       KHANGMATE HOME SCREEN              |
|  [Search Bar]  [Map]  [Nearby Houses]    |
+------------------------------------------+
| Featured Listings:                        |
|  - House 1 🔴                             |
|  - House 2 🟢                             |
|  - House 3 🟡                             |
+------------------------------------------+


Listing Screen:

+------------------------------------------+
| HOUSE DETAILS                             |
| Name: Bhutan Villa                        |
| Location: Thimphu                         |
| Price: Nu. 25,000 / month                 |
| [Photos] [Description] [Owner Info]       |
| [Chat] [Book Now]                          |
+------------------------------------------+
