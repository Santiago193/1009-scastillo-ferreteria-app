<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*, com.ferreteria.datos.QueryManager" %>

<%
    request.setCharacterEncoding("UTF-8");

    // ============================
    // FILTROS (MES + AÑO)
    // ============================
    int year = request.getParameter("year") == null ?
               java.time.LocalDate.now().getYear() :
               Integer.parseInt(request.getParameter("year"));

    int month = request.getParameter("month") == null ?
                java.time.LocalDate.now().getMonthValue() :
                Integer.parseInt(request.getParameter("month"));

    // ============================
    // SQL DE GANANCIAS
    // ============================
    String sqlGanancias =
        "SELECT " +
        " p.nombre AS producto, " +
        " SUM(d.cantidad) AS cantidad_vendida, " +
        " ROUND(AVG(d.precio_unitario), 2) AS precio_venta_promedio, " +
        " (SELECT ROUND(AVG(pp.precio_compra),2) FROM tb_producto_proveedor pp WHERE pp.id_producto = p.id_producto) AS precio_compra_promedio, " +
        " ROUND(SUM(d.cantidad * d.precio_unitario),2) AS ingresos_totales, " +
        " ROUND(SUM(d.cantidad * (SELECT AVG(pp.precio_compra) FROM tb_producto_proveedor pp WHERE pp.id_producto = p.id_producto)),2) AS costos_totales, " +
        " ROUND((SUM(d.cantidad * d.precio_unitario) - SUM(d.cantidad * (SELECT AVG(pp.precio_compra) FROM tb_producto_proveedor pp WHERE pp.id_producto = p.id_producto))),2) AS utilidad_total " +
        "FROM tb_venta_detalle d " +
        "JOIN tb_venta v ON v.id_venta = d.id_venta " +
        "JOIN tb_producto p ON p.id_producto = d.id_producto " +
        "WHERE EXTRACT(YEAR FROM v.fecha) = " + year + " " +
        "AND EXTRACT(MONTH FROM v.fecha) = " + month + " " +
        "GROUP BY p.id_producto, p.nombre " +
        "ORDER BY utilidad_total DESC";

    List<Map<String,Object>> lista = QueryManager.select(sqlGanancias);

    double totalIngresos = 0, totalCostos = 0, totalUtilidad = 0;
    for (Map<String,Object> f : lista) {
        totalIngresos += Double.parseDouble(f.get("ingresos_totales").toString());
        totalCostos   += Double.parseDouble(f.get("costos_totales").toString());
        totalUtilidad += Double.parseDouble(f.get("utilidad_total").toString());
    }
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Reporte de Ganancias</title>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
.graf-container {
    width: 380px;
    height: 220px;
    margin: 25px auto;
}
</style>

</head>

<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

    <h2 class="fw-bold text-primary text-center mb-4">Reporte de Ganancias</h2>

    <!-- ============================
         FILTRO DE FECHAS
    ============================ -->
    <form method="get" class="card shadow-sm p-3 mb-4">

        <div class="row g-3 align-items-end">

            <div class="col-md-3">
                <label class="form-label fw-bold">Año</label>
                <input type="number" name="year" class="form-control"
                       value="<%=year%>" min="2000" max="2100">
            </div>

            <div class="col-md-3">
                <label class="form-label fw-bold">Mes</label>
                <select name="month" class="form-select">
                    <%
                        String[] meses = {"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"};
                        for(int i=1;i<=12;i++){
                    %>
                        <option value="<%=i%>" <%=i==month?"selected":""%>>
                            <%=meses[i-1]%>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="col-md-3 mt-2">
                <button class="btn btn-primary w-100">🔍 Filtrar</button>
            </div>

        </div>
    </form>

    <!-- ============================
         TARJETAS RESUMEN
    ============================ -->
    <div class="row g-3 mb-4">

        <div class="col-md-4">
            <div class="card shadow-sm text-center border-success">
                <div class="card-body">
                    <h5 class="text-success">Ingresos</h5>
                    <p class="display-6 fw-bold">$<%=String.format("%.2f", totalIngresos)%></p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm text-center border-danger">
                <div class="card-body">
                    <h5 class="text-danger">Costos</h5>
                    <p class="display-6 fw-bold">$<%=String.format("%.2f", totalCostos)%></p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm text-center border-info">
                <div class="card-body">
                    <h5 class="text-info">Utilidad</h5>
                    <p class="display-6 fw-bold">$<%=String.format("%.2f", totalUtilidad)%></p>
                </div>
            </div>
        </div>

    </div>

    <!-- ============================
         TABLA DE GANANCIAS
    ============================ -->
    <div class="table-responsive">
        <table class="table table-bordered table-hover table-striped">

            <thead class="table-dark">
                <tr>
                    <th>Producto</th>
                    <th>Cant. Vendida</th>
                    <th>P. Venta Prom.</th>
                    <th>P. Compra Prom.</th>
                    <th>Ingresos</th>
                    <th>Costos</th>
                    <th>Utilidad</th>
                </tr>
            </thead>

            <tbody>
            <% for (Map<String,Object> f : lista) { %>
                <tr>
                    <td><%=f.get("producto")%></td>
                    <td><%=f.get("cantidad_vendida")%></td>
                    <td>$<%=f.get("precio_venta_promedio")%></td>
                    <td>$<%=f.get("precio_compra_promedio")%></td>
                    <td class="fw-bold text-success">$<%=f.get("ingresos_totales")%></td>
                    <td class="fw-bold text-danger">$<%=f.get("costos_totales")%></td>

                    <td class="fw-bold"
                        style="color:<%= Double.parseDouble(f.get("utilidad_total").toString())>=0 ? "green":"red" %>;">
                        $<%=f.get("utilidad_total")%>
                    </td>
                </tr>
            <% } %>
            </tbody>

        </table>
    </div>

    <!-- ============================
         GRÁFICO
    ============================ -->
    <div class="card shadow-sm mt-4">
        <div class="card-header bg-warning fw-bold">
            Gráfico de Resumen
        </div>
        <div class="card-body">
            <div class="graf-container">
                <canvas id="grafica"></canvas>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <script>
    new Chart(document.getElementById("grafica"), {
        type: "bar",
        data: {
            labels: ["Ingresos", "Costos", "Utilidad"],
            datasets: [{
                data: [<%=totalIngresos%>, <%=totalCostos%>, <%=totalUtilidad%>],
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

</div>

</body>
</html>
