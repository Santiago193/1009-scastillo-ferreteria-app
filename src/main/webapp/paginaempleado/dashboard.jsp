<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.ferreteria.datos.Conexion" %>

<%
int totalProductos = 0;
int bajoStock = 0;
int criticos = 0;
int sinUbicacion = 0;
int totalInventario = 0;

// Datos para gráficos
try (Conexion cn = new Conexion()) {
    ResultSet rs = cn.Consulta("SELECT cantidad, id_ubicacion FROM tb_producto WHERE activo=true");

    while(rs.next()){
        totalProductos++;

        int stock = rs.getInt("cantidad");
        totalInventario += stock;

        if(stock <= 5) criticos++;
        else if(stock <= 20) bajoStock++;

        if(rs.getObject("id_ubicacion") == null) sinUbicacion++;
    }
}
catch(Exception e){}

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard Empleado</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
.card-small {
    width: 220px;
    display: inline-block;
    margin-right: 15px;
}
.chart-container {
    width: 300px;
    height: 260px;
    margin: auto;
}
</style>

</head>
<body class="bodygeneral">

<jsp:include page="../head&foot/menuu.jsp" />


<div class="container py-4">

<h2 class="text-primary mb-4">Dashboard Empleado</h2>

<!-- =============================================================
    TARJETAS RESUMEN
============================================================== -->
<div class="d-flex flex-wrap gap-3">

<div class="card card-small shadow-sm text-center p-3">
    <h5>Total Productos</h5>
    <h2 class="text-primary"><%= totalProductos %></h2>
</div>

<div class="card card-small shadow-sm text-center p-3">
    <h5>Bajo Stock</h5>
    <h2 class="text-warning"><%= bajoStock %></h2>
</div>

<div class="card card-small shadow-sm text-center p-3">
    <h5>Críticos</h5>
    <h2 class="text-danger"><%= criticos %></h2>
</div>

<div class="card card-small shadow-sm text-center p-3">
    <h5>Sin Ubicación</h5>
    <h2 class="text-secondary"><%= sinUbicacion %></h2>
</div>

<div class="card card-small shadow-sm text-center p-3">
    <h5>Inventario Total</h5>
    <h2 class="text-success"><%= totalInventario %></h2>
</div>

</div>

<hr>

<!-- =============================================================
    GRÁFICO 1: BARRAS (ESTADO GENERAL)
============================================================== -->
<div class="row mt-3">
<div class="col-md-6 text-center">
<h5>Estado del Inventario</h5>
<div class="chart-container">
    <canvas id="chartBarras"></canvas>
</div>
</div>

<!-- =============================================================
    GRÁFICO 2: DONA (DISTRIBUCIÓN)
============================================================== -->
<div class="col-md-6 text-center">
<h5>Distribución de Riesgos</h5>
<div class="chart-container">
    <canvas id="chartDona"></canvas>
</div>
</div>
</div>

<hr>

<!-- =============================================================
    TABLA: TOP 5 CON MENOR STOCK
============================================================== -->
<h4 class="mt-4">Productos con Menor Stock</h4>

<table class="table table-bordered table-striped">
<thead class="table-secondary">
<tr>
    <th>Producto</th>
    <th>Stock</th>
</tr>
</thead>
<tbody>

<%
try (Conexion cn = new Conexion()) {
    ResultSet rs = cn.Consulta(
        "SELECT nombre, cantidad FROM tb_producto WHERE activo=true ORDER BY cantidad ASC LIMIT 5"
    );

    while(rs.next()){
%>

<tr>
    <td><%= rs.getString("nombre") %></td>
    <td><%= rs.getInt("cantidad") %></td>
</tr>

<%
    }
}
catch(Exception e){
    out.print("<tr><td colspan='2'>ERROR: "+e.getMessage()+"</td></tr>");
}
%>

</tbody>
</table>

</div> <!-- container -->

<!-- =============================================================
    GRÁFICOS JS
============================================================== -->
<script>
const barras = document.getElementById('chartBarras').getContext('2d');
new Chart(barras, {
    type: 'bar',
    data: {
        labels: ['OK', 'Bajo Stock', 'Críticos'],
        datasets: [{
            label: 'Cantidad',
            data: [
                <%= totalProductos - bajoStock - criticos %>,
                <%= bajoStock %>,
                <%= criticos %>
            ],
            backgroundColor: ['#4CAF50', '#FFC107', '#F44336']
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false
    }
});

const dona = document.getElementById('chartDona').getContext('2d');
new Chart(dona, {
    type: 'doughnut',
    data: {
        labels: ['OK', 'Bajo', 'Crítico'],
        datasets: [{
            data: [
                <%= totalProductos - bajoStock - criticos %>,
                <%= bajoStock %>,
                <%= criticos %>
            ],
            backgroundColor: ['#4CAF50', '#FFC107', '#F44336']
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false
    }
});
</script>

</body>
</html>
