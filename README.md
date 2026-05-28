# Ferretería El Ejército — Web Management System

A role-based internal web application for managing inventory, sales, purchases, and reporting at a local hardware store. Built with Java Servlets/JSP and PostgreSQL, deployed on Apache Tomcat.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
- [User Roles](#user-roles)
- [Known Security Notes](#known-security-notes)

---

## Overview

This system replaces manual paper-based processes at Ferretería El Ejército with a centralized digital solution. It covers the full operational cycle: product catalog management, supplier purchases, point-of-sale transactions, inventory tracking, and financial reporting — all behind a role-based access control layer.

---

## Features

### Administrator
- **Dashboard** — real-time KPI cards (monthly sales, purchases, profit), top-5 best-selling products chart, critical stock alerts, and recent sales feed
- **Product Management** — add, edit, and soft-delete products with barcode, brand, unit, location (shelf/column/row), minimum stock threshold, and image URL
- **Purchase Management** — register purchases per supplier, auto-updates inventory via PostgreSQL triggers, inline edit/delete of purchase history
- **Supplier Management** — register and list suppliers directly from the purchases page
- **Sales History** — full sales log with employee, product, quantity, unit price, and total
- **Profit Report** — filterable by month/year; shows revenue, cost, and margin per product with a summary bar chart
- **Inventory Report** — critical stock section (below minimum) and full inventory listing, both with inline search and edit
- **User Management** — create, edit, block/unblock, and delete system users; assign roles (Admin, Employee, User)
- **Company Configuration** — update company name, slogan, RUC, contact details, logo, social media links; changes persist to the database immediately

### Employee
- **Point of Sale (POS)** — session-based shopping cart with barcode scanner input, product search modal, real-time stock validation, keyboard shortcuts (Ctrl+A add, Ctrl+F finalize, Ctrl+L clear, Ctrl+B search modal, Ctrl+U last sales), and audio feedback
- **Dashboard** — inventory health overview with bar and doughnut charts (OK / low stock / critical), total units in stock, and top-5 lowest-stock products
- **Product Catalog** — read-only product list with search
- **Inventory Report** — same critical/full inventory view as admin

---

## Technology Stack

| Layer | Technology |
|---|---|
| Backend | Java 11+, JSP (Jakarta EE) |
| Frontend | Bootstrap 5.3, Chart.js, Vanilla JS |
| Database | PostgreSQL 18 |
| JDBC Driver | `postgresql-42.7.8.jar` |
| Server | Apache Tomcat 9+ |
| Build | Eclipse Dynamic Web Project / Maven-compatible layout |
| Version Control | Git / GitHub |

---

## Project Structure

```
src/
└── main/
    ├── java/com/ferreteria/
    │   ├── admin/
    │   │   ├── Compra.java        # Purchase entity — list and register purchases
    │   │   ├── Producto.java      # Product entity — CRUD, stock queries
    │   │   └── Proveedor.java     # Supplier entity — list and insert
    │   ├── datos/
    │   │   ├── Conexion.java      # JDBC connection wrapper (plain + prepared statements)
    │   │   ├── QueryManager.java  # Static helpers: select, update, parameterized queries
    │   │   └── TestConexion.java  # Standalone connection test
    │   ├── empresa/
    │   │   └── Empresa.java       # Company bean — auto-loads from DB, setter triggers UPDATE
    │   └── seguridad/
    │       ├── Pagina.java        # Builds role-based navigation menu from DB
    │       └── Usuario.java       # User entity — login, CRUD, role management
    └── webapp/
        ├── dinamica/
        │   ├── tabla.jsp          # Reusable dynamic table with inline edit/delete
        │   └── form.jsp           # Reusable dynamic insert form
        ├── general/general.css
        ├── head&foot/             # Shared header, footer, and navigation menu
        ├── js/
        │   ├── ventas.js          # POS cart logic (fetch-based autocomplete version)
        │   └── recuperar.js
        ├── paginaadmin/           # Admin-only pages
        │   ├── dashboard.jsp
        │   ├── productos.jsp
        │   ├── compras.jsp
        │   ├── ventas.jsp
        │   ├── reporte_ganancias.jsp
        │   ├── reporte_inventario.jsp
        │   ├── usuarios.jsp
        │   ├── config_empresa.jsp
        │   └── logout.jsp
        ├── paginaempleado/        # Employee-only pages
        │   ├── dashboard.jsp
        │   ├── ventas.jsp         # Full POS with cart, keyboard shortcuts, audio
        │   ├── productos.jsp
        │   ├── reporte_inventario.jsp
        │   └── logout.jsp
        ├── paginavisitante/
        ├── index.jsp
        ├── login.jsp
        ├── validarLogin.jsp
        ├── registro.jsp
        ├── nuevoCliente.jsp
        └── menu.jsp               # Role dispatcher — redirects to correct dashboard
database.sql                       # Full PostgreSQL dump (schema + seed data + triggers)
```

---

## Database Schema

The database uses **PostgreSQL triggers** to maintain data integrity automatically — no manual stock updates are needed in application code.

| Table | Description |
|---|---|
| `tb_usuario` | System users with role and blocked flag |
| `tb_perfil` | Roles: ADMIN (1), EMPLEADO (2), USUARIO (3) |
| `tb_pagina` | Page URLs registered per role |
| `tb_perfilpagina` | Role ↔ page access mapping |
| `tb_producto` | Product catalog with barcode, stock, location, active flag |
| `tb_ubicacion` | Physical shelf locations (shelf / column / row) |
| `tb_proveedor` | Supplier directory |
| `tb_producto_proveedor` | Product ↔ supplier with last purchase price |
| `tb_compra` | Purchase header (supplier, date, total) |
| `tb_compra_detalle` | Purchase line items |
| `tb_venta` | Sale header (employee, date, total) |
| `tb_venta_detalle` | Sale line items |
| `tb_empresa` | Company profile (name, logo, contacts, social media) |
| `tb_estadocivil` | Civil status lookup |
| `tb_iva` | VAT rate history |

### Triggers

| Trigger | Event | Effect |
|---|---|---|
| `trg_compra_insert` | INSERT on `tb_compra_detalle` | Increases product stock |
| `trg_compra_update` | UPDATE on `tb_compra_detalle` | Adjusts stock by delta |
| `trg_compra_delete` | DELETE on `tb_compra_detalle` | Reverts stock increase |
| `trg_venta_insert` | INSERT on `tb_venta_detalle` | Decreases stock, raises exception if insufficient |
| `trg_venta_update` | UPDATE on `tb_venta_detalle` | Adjusts stock by delta |
| `trg_venta_delete` | DELETE on `tb_venta_detalle` | Restores sold stock |
| `trg_protect_stock` | BEFORE UPDATE on `tb_producto` | Prevents negative stock |
| `trg_total_compra` | After detail change | Recalculates purchase total |
| `trg_total_venta` | After detail change | Recalculates sale total |

---

## Getting Started

### Prerequisites

- Java 11 or higher
- Apache Tomcat 9+
- PostgreSQL 14+
- Eclipse IDE for Enterprise Java (or any IDE with Tomcat integration)

### Database Setup

1. Create a PostgreSQL database:
   ```sql
   CREATE DATABASE ferre;
   ```

2. Restore the schema and seed data:
   ```bash
   psql -U postgres -d ferre -f database.sql
   ```

### Application Configuration

Update the database credentials in `src/main/java/com/ferreteria/datos/Conexion.java`:

```java
private final String user   = "your_db_user";
private final String pwd    = "your_db_password";
private final String cadena = "jdbc:postgresql://localhost:5432/ferre";
```

> **Note:** Credentials are currently hardcoded. For production, move them to a `db.properties` file or environment variables and add that file to `.gitignore`.

### Deploy

1. Import the project into Eclipse as a **Dynamic Web Project**
2. Add the project to your Tomcat server
3. Start Tomcat and navigate to:
   ```
   http://localhost:8080/ferreteria/
   ```

### Default Access

The database seed includes pre-configured roles and page permissions. Create an initial admin user directly in the database or through the registration page, then assign `id_perfil = 1` (ADMIN) via SQL.

---

## User Roles

| Role | ID | Access |
|---|---|---|
| ADMIN | 1 | Full access — all pages including user and company management |
| EMPLEADO | 2 | POS, product catalog, inventory report, employee dashboard |
| USUARIO | 3 | Visitor-level access (limited, extensible) |

Access control is enforced at the page level via the `tb_perfilpagina` table. The `menu.jsp` dispatcher reads the session role and redirects to the appropriate dashboard.

---

## Known Security Notes

The following issues exist in the current codebase and should be addressed before any production deployment:

| Issue | Location | Recommendation |
|---|---|---|
| Hardcoded DB credentials | `Conexion.java` | Move to `db.properties` or environment variables |
| Passwords stored in plain text | `tb_usuario`, `Usuario.java` | Hash with BCrypt before storing |
| Plain-text password comparison at login | `Usuario.java` — `verificarUsuario()` | Compare against BCrypt hash |
| Password visible in registration confirmation | `nuevoCliente.jsp` | Remove password from confirmation table |
| Password edit field uses `type="text"` | `usuarios.jsp` | Change to `type="password"` |
| SQL concatenation in several JSP pages | `compras.jsp`, `productos.jsp`, `tabla.jsp` | Replace with parameterized `PreparedStatement` calls |

---

## Repository

[https://github.com/Santiago193/1009-scastillo-ferreteria-app](https://github.com/Santiago193/1009-scastillo-ferreteria-app)
