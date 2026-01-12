<%@ page language="java" 
    contentType="text/html; charset=UTF-8" 
    pageEncoding="UTF-8"
    buffer="8kb"
    trimDirectiveWhitespaces="true"
%>

<%
    // 🔥 Asegura que todos los parámetros GET y POST manejen tildes y ñ correctamente
    request.setCharacterEncoding("UTF-8");
    response.setCharacterEncoding("UTF-8");
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Reporte de Inventario</title>

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .critico {
            background-color: #ffebee !important;
        }
        .titulo-seccion {
            margin-top: 30px;
            color: #0d6efd;
            font-weight: bold;
            border-left: 6px solid #0d6efd;
            padding-left: 10px;
        }
    </style>
</head>

<body class="bodygeneral">
<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

    <!-- 🚨 PRODUCTOS EN STOCK CRÍTICO -->
    <h2 class="titulo-seccion">🚨 Productos en Estado Crítico</h2>

    <div class="card shadow-sm mb-4 border-danger">
        <div class="card-header bg-danger text-white fw-bold">
            Stock Crítico
        </div>
        <div class="card-body">

            <jsp:include page="../dinamica/tabla.jsp">
                <jsp:param name="tituloTabla" value="Stock Crítico" />
                <jsp:param name="tablaBase" value="tb_producto" />
                <jsp:param name="sql" value="
                    SELECT 
                        id_producto AS ID,
                        nombre AS Producto,
                        cantidad AS Stock,
                        stock_minimo AS Minimo,
                        marca,
                        unidad
                    FROM tb_producto
                    WHERE cantidad < stock_minimo
                    ORDER BY cantidad ASC
                " />
                <jsp:param name="tablasColumnas" value='{}' />
            </jsp:include>

        </div>
    </div>

    <!-- 📦 INVENTARIO COMPLETO -->
    <h2 class="titulo-seccion">📦 Inventario Completo</h2>

    <div class="card shadow-sm mb-4 border-primary">
        <div class="card-header bg-primary text-white fw-bold">
            Inventario Total
        </div>
        <div class="card-body">

            <jsp:include page="../dinamica/tabla.jsp">
                <jsp:param name="tituloTabla" value="Inventario Total" />
                <jsp:param name="tablaBase" value="tb_producto" />
                <jsp:param name="sql" value="
                    SELECT 
                        id_producto AS ID,
                        nombre AS Producto,
                        cantidad AS Stock,
                        stock_minimo AS Minimo,
                        marca,
                        unidad
                    FROM tb_producto
                    ORDER BY nombre ASC
                " />
                <jsp:param name="tablasColumnas" value='{}' />
            </jsp:include>

        </div>
    </div>

</div> <!-- container -->

</body>
</html>
