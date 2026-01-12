<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*, com.ferreteria.datos.QueryManager" %>

<%
    request.setCharacterEncoding("UTF-8");

    int year = java.time.LocalDate.now().getYear();
    int month = java.time.LocalDate.now().getMonthValue();

    // =============================
    // 1. TOTALES PRINCIPALES
    // =============================
    int totalProductos = Integer.parseInt(
        QueryManager.select("SELECT COUNT(*) AS c FROM tb_producto").get(0).get("c").toString()
    );

    double totalVentasMes = Double.parseDouble(
        QueryManager.select(
            "SELECT COALESCE(SUM(total),0) AS suma FROM tb_venta " +
            "WHERE EXTRACT(YEAR FROM fecha)=" + year +
            " AND EXTRACT(MONTH FROM fecha)=" + month
        ).get(0).get("suma").toString()
    );

    double totalComprasMes = Double.parseDouble(
        QueryManager.select(
            "SELECT COALESCE(SUM(total),0) AS suma FROM tb_compra " +
            "WHERE EXTRACT(YEAR FROM fecha)=" + year +
            " AND EXTRACT(MONTH FROM fecha)=" + month
        ).get(0).get("suma").toString()
    );

    double utilidadMes = totalVentasMes - totalComprasMes;

    // =============================
    // 2. TOP DE PRODUCTOS
    // =============================
    List<Map<String,Object>> topVentas =
        QueryManager.select(
            "SELECT p.nombre, SUM(d.cantidad) AS cant " +
            "FROM tb_venta_detalle d " +
            "JOIN tb_producto p ON p.id_producto = d.id_producto " +
            "JOIN tb_venta v ON v.id_venta = d.id_venta " +
            "WHERE EXTRACT(YEAR FROM v.fecha)=" + year +
            " AND EXTRACT(MONTH FROM v.fecha)=" + month +
            " GROUP BY p.nombre ORDER BY cant DESC LIMIT 5"
        );

    // =============================
    // 3. STOCK CRÍTICO
    // =============================
    List<Map<String,Object>> stockCritico =
        QueryManager.select(
            "SELECT nombre, cantidad, stock_minimo FROM tb_producto " +
            "WHERE cantidad <= stock_minimo ORDER BY cantidad ASC LIMIT 5"
        );

    // =============================
    // 4. ÚLTIMAS 5 VENTAS
    // =============================
    List<Map<String,Object>> ultimasVentas =
        QueryManager.select(
            "SELECT v.id_venta, v.total, v.fecha, p.nombre AS producto, d.cantidad " +
            "FROM tb_venta v " +
            "JOIN tb_venta_detalle d ON d.id_venta = v.id_venta " +
            "JOIN tb_producto p ON p.id_producto = d.id_producto " +
            "ORDER BY v.id_venta DESC LIMIT 5"
        );
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Dashboard</title>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

<style>
.grafico-container {
    height: 260px;
}
</style>
</head>

<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

<h2 class="text-center fw-bold text-primary mb-4">Dashboard</h2>

<!-- ========================================
     TARJETAS PRINCIPALES
======================================== -->
<div class="row g-3 mb-4">

    <div class="col-md-3">
        <div class="card text-center shadow-sm border-primary">
            <div class="card-body">
                <h5 class="card-title text-primary">Productos Totales</h5>
                <p class="display-6 fw-bold"><%=totalProductos%></p>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card text-center shadow-sm border-success">
            <div class="card-body">
                <h5 class="card-title text-success">Ventas del Mes</h5>
                <p class="display-6 fw-bold">$<%=String.format("%.2f", totalVentasMes)%></p>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card text-center shadow-sm border-warning">
            <div class="card-body">
                <h5 class="card-title text-warning">Compras del Mes</h5>
                <p class="display-6 fw-bold">$<%=String.format("%.2f", totalComprasMes)%></p>
            </div>
        </div>
    </div>

    <div class="col-md-3">
        <div class="card text-center shadow-sm border-danger">
            <div class="card-body">
                <h5 class="card-title text-danger">Utilidad del Mes</h5>
                <p class="display-6 fw-bold" style="color:<%=utilidadMes>=0?"green":"red"%>;">
                    $<%=String.format("%.2f", utilidadMes)%>
                </p>
            </div>
        </div>
    </div>

</div>


<!-- ========================================
     GRÁFICO 1 — RESUMEN
======================================== -->
<div class="card shadow-sm mb-4">
    <div class="card-header bg-primary text-white">
        <h5 class="mb-0">Resumen Mensual</h5>
    </div>
    <div class="card-body">
        <div class="grafico-container">
            <canvas id="graf1"></canvas>
        </div>
    </div>
</div>

<script>
new Chart(document.getElementById("graf1"), {
    type: "bar",
    data: {
        labels: ["Ingresos", "Costos", "Utilidad"],
        datasets: [{
            data: [<%=totalVentasMes%>, <%=totalComprasMes%>, <%=utilidadMes%>],
            backgroundColor: ["#198754", "#dc3545", "#0d6efd"]
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: { legend: { display:false }}
    }
});
</script>


<!-- ========================================
     GRÁFICO 2 — MÁS VENDIDOS
======================================== -->
<div class="card shadow-sm mb-4">
    <div class="card-header bg-success text-white">
        <h5 class="mb-0">Top 5 Productos Más Vendidos</h5>
    </div>
    <div class="card-body">
        <div class="grafico-container">
            <canvas id="graf2"></canvas>
        </div>
    </div>
</div>

<script>
new Chart(document.getElementById("graf2"), {
    type: "pie",
    data: {
        labels: [
            <% for (Map<String,Object> m : topVentas) { %>
                "<%=m.get("nombre")%>",
            <% } %>
        ],
        datasets: [{
            data: [
                <% for (Map<String,Object> m : topVentas) { %>
                    <%=m.get("cant")%>,
                <% } %>
            ],
            backgroundColor: ["#0d6efd","#198754","#ffc107","#6f42c1","#dc3545"]
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false
    }
});
</script>


<!-- ========================================
     STOCK CRÍTICO
======================================== -->
<div class="card shadow-sm mb-4">
    <div class="card-header bg-danger text-white">
        <h5 class="mb-0">Productos con Stock Crítico</h5>
    </div>
    <div class="card-body">

        <table class="table table-striped table-hover">
            <thead class="table-dark">
                <tr>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Mínimo</th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String,Object> r : stockCritico) { %>
                <tr>
                    <td><%=r.get("nombre")%></td>
                    <td class="fw-bold text-danger"><%=r.get("cantidad")%></td>
                    <td><%=r.get("stock_minimo")%></td>
                </tr>
            <% } %>
            </tbody>
        </table>

    </div>
</div>


<!-- ========================================
     ÚLTIMAS 5 VENTAS
======================================== -->
<div class="card shadow-sm mb-5">
    <div class="card-header bg-info text-white">
        <h5 class="mb-0">Últimas 5 Ventas</h5>
    </div>
    <div class="card-body">

        <table class="table table-striped table-hover">
            <thead class="table-dark">
                <tr>
                    <th>ID Venta</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Total</th>
                    <th>Fecha</th>
                </tr>
            </thead>
            <tbody>
            <% for (Map<String,Object> v : ultimasVentas) { %>
                <tr>
                    <td><%=v.get("id_venta")%></td>
                    <td><%=v.get("producto")%></td>
                    <td><%=v.get("cantidad")%></td>
                    <td>$<%=v.get("total")%></td>
                    <td><%=v.get("fecha")%></td>
                </tr>
            <% } %>
            </tbody>
        </table>

    </div>
</div>


</div><!-- /.container -->

</body>
</html>
