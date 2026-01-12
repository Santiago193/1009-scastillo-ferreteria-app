<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.ferreteria.datos.Conexion" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Reporte de Inventario</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
.table thead th {
    background-color: #0d6efd;
    color: white;
    text-align: center;
}

.ok { background-color: #d4edda !important; }        /* verde claro */
.bajo { background-color: #fff3cd !important; }      /* amarillo */
.critico { background-color: #f8d7da !important; }   /* rojo */

.card { border-radius: 10px; margin-bottom: 30px; }
</style>
</head>
<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />


<div class="container py-4">

<h2 class="text-primary mb-4">Reporte de Inventario</h2>

<!-- ======================================================
     1. INVENTARIO GENERAL
====================================================== -->
<div class="card shadow">
<div class="card-header bg-primary text-white">
    <h5 class="m-0">Inventario General</h5>
</div>
<div class="card-body">

<table class="table table-bordered table-striped">
<thead>
<tr>
    <th>Producto</th>
    <th>Precio</th>
    <th>Stock</th>
    <th>Estado</th>
</tr>
</thead>
<tbody>

<%
try (Conexion cn = new Conexion()) {
    ResultSet rs = cn.Consulta(
        "SELECT nombre, precio_venta, cantidad FROM tb_producto WHERE activo=true ORDER BY nombre"
    );

    while(rs.next()){
        int stock = rs.getInt("cantidad");
        String estadoClase = "";
        String estadoTxt = "";

        if (stock <= 5) { estadoClase="critico"; estadoTxt="Crítico"; }
        else if (stock <= 20) { estadoClase="bajo"; estadoTxt="Bajo"; }
        else { estadoClase="ok"; estadoTxt="OK"; }
%>

<tr class="<%= estadoClase %>">
    <td><%= rs.getString("nombre") %></td>
    <td>$<%= rs.getDouble("precio_venta") %></td>
    <td><%= stock %></td>
    <td><%= estadoTxt %></td>
</tr>

<%
    }
}
catch(Exception e){
    out.print("<tr><td colspan='4' class='text-danger'>ERROR: " + e.getMessage() + "</td></tr>");
}
%>

</tbody>
</table>

</div>
</div>

<!-- ======================================================
     2. BAJO STOCK
====================================================== -->
<div class="card shadow">
<div class="card-header bg-warning">
    <h5 class="m-0 text-dark">Productos con Bajo Stock (6–20 unidades)</h5>
</div>
<div class="card-body">

<table class="table table-bordered">
<thead>
<tr>
    <th>Producto</th>
    <th>Stock</th>
</tr>
</thead>
<tbody>

<%
try (Conexion cn = new Conexion()) {
    ResultSet rs = cn.Consulta(
        "SELECT nombre, cantidad FROM tb_producto WHERE activo=true AND cantidad BETWEEN 6 AND 20 ORDER BY cantidad ASC"
    );

    boolean hayDatos = false;

    while(rs.next()){
        hayDatos = true;
%>

<tr class="bajo">
    <td><%= rs.getString("nombre") %></td>
    <td><%= rs.getInt("cantidad") %></td>
</tr>

<%
    }

    if(!hayDatos){
        out.print("<tr><td colspan='2' class='text-muted'>No hay productos con bajo stock.</td></tr>");
    }
}
catch(Exception e){
    out.print("<tr><td colspan='2' class='text-danger'>ERROR: "+e.getMessage()+"</td></tr>");
}
%>

</tbody>
</table>

</div>
</div>

<!-- ======================================================
     3. PRODUCTOS CRÍTICOS
====================================================== -->
<div class="card shadow">
<div class="card-header bg-danger text-white">
    <h5 class="m-0">Productos en Estado Crítico (≤ 5 unidades)</h5>
</div>
<div class="card-body">

<table class="table table-bordered">
<thead>
<tr>
    <th>Producto</th>
    <th>Stock</th>
</tr>
</thead>
<tbody>

<%
try (Conexion cn = new Conexion()) {
    ResultSet rs = cn.Consulta(
        "SELECT nombre, cantidad FROM tb_producto WHERE activo=true AND cantidad <= 5 ORDER BY cantidad ASC"
    );

    boolean hay = false;

    while(rs.next()){
        hay = true;
%>

<tr class="critico">
    <td><%= rs.getString("nombre") %></td>
    <td><%= rs.getInt("cantidad") %></td>
</tr>

<%
    }

    if(!hay){
        out.print("<tr><td colspan='2' class='text-muted'>No hay productos críticos.</td></tr>");
    }
}
catch(Exception e){
    out.print("<tr><td colspan='2' class='text-danger'>ERROR: "+e.getMessage()+"</td></tr>");
}
%>

</tbody>
</table>

</div>
</div>


</div> <!-- container -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
