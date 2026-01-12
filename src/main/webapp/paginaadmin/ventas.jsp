<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ventas</title>

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .titulo {
            color: #0d6efd;
            font-weight: bold;
            margin-bottom: 20px;
            border-left: 6px solid #0d6efd;
            padding-left: 10px;
        }
    </style>
</head>

<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

    <h2 class="titulo">Historial de Ventas</h2>

    <!-- ==========================
         CARD CONTENEDORA
    ========================== -->
    <div class="card shadow-sm border-primary">

        <div class="card-header bg-primary text-white fw-bold">
            Historial de Ventas
        </div>

        <div class="card-body">

            <!-- ========== TABLA DINÁMICA ========= -->
            <jsp:include page="../dinamica/tabla.jsp">
                <jsp:param name="tituloTabla" value="Historial de Ventas" />
                <jsp:param name="tablaBase" value="tb_venta" />
                <jsp:param name="sql" value="
                    SELECT 
                        v.id_venta AS ID,
                        COALESCE(u.nombre || ' ' || u.apellido, 'Desconocido') AS empleado,
                        p.nombre AS producto,
                        d.cantidad,
                        d.precio_unitario,
                        v.total,
                        v.fecha
                    FROM tb_venta v
                    JOIN tb_venta_detalle d ON d.id_venta = v.id_venta
                    JOIN tb_producto p ON p.id_producto = d.id_producto
                    LEFT JOIN tb_usuario u ON u.id_usuario = v.id_usuario
                    ORDER BY v.id_venta DESC
                " />
                <jsp:param name="tablasColumnas" value='{"cantidad":"tb_venta_detalle","precio_unitario":"tb_venta_detalle","total":"tb_venta","fecha":"tb_venta"}' />
            </jsp:include>

        </div>
    </div>

</div>

</body>
</html>
