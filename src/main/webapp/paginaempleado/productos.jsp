<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, com.ferreteria.datos.Conexion" %>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Productos - Solo Lectura</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<link rel="stylesheet" href="general/general.css">

<style>
.table thead th {
    background-color: #0d6efd;
    color: white;
    text-align: center;
}
.table tbody td {
    vertical-align: middle;
}
.ubicacion {
    font-size: 0.9rem;
    color: #444;
}
.card {
    border-radius: 10px;
}
</style>

<script>
// =====================================================
//  BUSCADOR EN VIVO POR NOMBRE
// =====================================================
function filtrarProductos() {
    let filtro = document.getElementById("inputBusqueda").value.toLowerCase();
    let filas  = document.querySelectorAll("#tablaProductos tbody tr");

    filas.forEach(fila => {
        let nombre = fila.querySelector(".nombreProducto").textContent.toLowerCase();
        fila.style.display = nombre.includes(filtro) ? "" : "none";
    });
}
</script>

</head>
<body class="bodygeneral">
<!-- Menú -->
<jsp:include page="../head&foot/menuu.jsp" />


<div class="container py-4">

<h2 class="text-primary mb-4">Listado de Productos (Solo Lectura)</h2>

<!-- ======================== BUSCADOR ======================== -->
<div class="card shadow mb-3">
<div class="card-body">
    <label class="form-label">Buscar producto por nombre</label>
    <input type="text" id="inputBusqueda" class="form-control"
           placeholder="Escribe para filtrar..."
           onkeyup="filtrarProductos()">
</div>
</div>

<!-- ======================== TABLA ======================== -->
<div class="card shadow">
<div class="card-body">

<table class="table table-striped table-bordered" id="tablaProductos">
<thead>
<tr>
    <th>Nombre</th>
    <th>Precio Venta</th>
    <th>Stock</th>
    <th>Ubicación</th>
</tr>
</thead>
<tbody>

<%
try (Conexion cn = new Conexion()) {

    String sql = 
        "SELECT p.nombre, p.precio_venta, p.cantidad, " +
        "u.estanteria, u.columna, u.fila " +
        "FROM tb_producto p " +
        "LEFT JOIN tb_ubicacion u ON p.id_ubicacion = u.id_ubicacion " +
        "WHERE p.activo = true ORDER BY p.nombre ASC";

    ResultSet rs = cn.Consulta(sql);

    while(rs.next()){
%>

<tr>
    <td class="nombreProducto"><%= rs.getString("nombre") %></td>

    <td class="text-success fw-bold">
        $<%= rs.getDouble("precio_venta") %>
    </td>

    <td class="text-center">
        <%= rs.getInt("cantidad") %>
    </td>

    <td class="ubicacion">
        <%
        String est = rs.getString("estanteria");
        String col = rs.getString("columna");
        String fil = rs.getString("fila");

        if (est == null) {
            out.print("<span class='text-danger'>Sin ubicación</span>");
        } else {
            out.print("Estantería: <b>" + est + "</b> — Col: <b>" + col + "</b> — Fila: <b>" + fil + "</b>");
        }
        %>
    </td>
</tr>

<%
    } // FIN while
} catch(Exception e){
    out.print("<tr><td colspan='4' class='text-danger'>Error: " + e.getMessage() + "</td></tr>");
}
%>

</tbody>
</table>

</div>
</div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
