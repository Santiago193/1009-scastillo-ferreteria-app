<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*, com.ferreteria.datos.QueryManager" %>

<%
    request.setCharacterEncoding("UTF-8");

    /* ==========================================================
       ACCIÓN: AGREGAR PRODUCTO
    ========================================================== */
    if ("agregarProducto".equals(request.getParameter("accion"))) {

        String codigo  = request.getParameter("codigo_barra");
        String nombre  = request.getParameter("nombre");
        String marca   = request.getParameter("marca");
        String unidad  = request.getParameter("unidad");
        String desc    = request.getParameter("descripcion");
        double precio  = Double.parseDouble(request.getParameter("precio_venta"));
        int stockMin   = Integer.parseInt(request.getParameter("stock_minimo"));
        String img     = request.getParameter("imagen_url");
        int ubic       = Integer.parseInt(request.getParameter("ubicacion"));
        int cantidad   = Integer.parseInt(request.getParameter("cantidad"));

        String sql = "INSERT INTO tb_producto (codigo_barra,nombre,marca,unidad,descripcion,precio_venta,stock_minimo,imagen_url,id_ubicacion,cantidad,activo) " +
                     "VALUES ('"+codigo+"','"+nombre+"','"+marca+"','"+unidad+"','"+desc+"',"+precio+","+stockMin+",'"+img+"',"+ubic+","+cantidad+", true)";

        QueryManager.update(sql);
        response.sendRedirect("productos.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: AGREGAR UBICACIÓN
    ========================================================== */
    if ("agregarUbicacion".equals(request.getParameter("accion"))) {

        int est = Integer.parseInt(request.getParameter("estanteria"));
        String col = request.getParameter("columna");
        int fila = Integer.parseInt(request.getParameter("fila"));

        String sqlU = "INSERT INTO tb_ubicacion (estanteria,columna,fila) VALUES ("+est+",'"+col+"',"+fila+")";

        QueryManager.update(sqlU);
        response.sendRedirect("productos.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: ACTUALIZAR PRODUCTO
    ========================================================== */
    if ("actualizarProducto".equals(request.getParameter("accion"))) {

        String id = request.getParameter("id");

        String sqlUp = "UPDATE tb_producto SET " +
                       "codigo_barra='" + request.getParameter("codigo_barra") + "'," +
                       "nombre='" + request.getParameter("nombre") + "'," +
                       "marca='" + request.getParameter("marca") + "'," +
                       "unidad='" + request.getParameter("unidad") + "'," +
                       "precio_venta=" + request.getParameter("precio_venta") + "," +
                       "cantidad=" + request.getParameter("cantidad") + "," +
                       "stock_minimo=" + request.getParameter("stock_minimo") + "," +
                       "imagen_url='" + request.getParameter("imagen_url") + "'" +
                       " WHERE id_producto=" + id;

        QueryManager.update(sqlUp);
        response.sendRedirect("productos.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: ELIMINAR PRODUCTO (DESACTIVACIÓN)
    ========================================================== */
    if ("eliminarProducto".equals(request.getParameter("accion"))) {

        String id = request.getParameter("id");

        // 🔹 NO BORRA EL PRODUCTO — SOLO LO DESACTIVA
        String sqlDel = "UPDATE tb_producto SET activo = false WHERE id_producto=" + id;

        QueryManager.update(sqlDel);

        response.sendRedirect("productos.jsp");
        return;
    }

    /* ==========================================================
       LISTAS DE PRODUCTOS Y UBICACIONES
    ========================================================== */

    // 🔹 SOLO PRODUCTOS ACTIVOS
    List<Map<String,Object>> productos = QueryManager.select(
        "SELECT p.*, " +
        " (SELECT pp.precio_compra FROM tb_producto_proveedor pp WHERE pp.id_producto = p.id_producto ORDER BY pp.id DESC LIMIT 1) AS precio_compra " +
        " FROM tb_producto p WHERE activo = true ORDER BY p.id_producto"
    );

    List<Map<String,Object>> ubicaciones = QueryManager.select(
        "SELECT * FROM tb_ubicacion ORDER BY estanteria, columna, fila"
    );

%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Productos</title>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<style>
.img-mini { width:40px; height:40px; border-radius:6px; object-fit:cover; }
.card { margin-bottom:30px; }
</style>

</head>

<body class="bodygeneral">

<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

<!-- =======================================================
     FORMULARIO AGREGAR PRODUCTO
======================================================= -->
<div class="card shadow-sm border-primary">
    <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Agregar Producto</h4>
    </div>

    <div class="card-body">

        <form method="post" class="row g-3">
            <input type="hidden" name="accion" value="agregarProducto">

            <div class="col-md-4">
                <label class="form-label">Código de barras</label>
                <input type="text" name="codigo_barra" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Nombre</label>
                <input type="text" name="nombre" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Marca</label>
                <input type="text" name="marca" class="form-control">
            </div>

            <div class="col-md-4">
                <label class="form-label">Unidad</label>
                <input type="text" name="unidad" class="form-control">
            </div>

            <div class="col-md-8">
                <label class="form-label">Descripción</label>
                <textarea name="descripcion" class="form-control"></textarea>
            </div>

            <div class="col-md-4">
                <label class="form-label">Precio venta</label>
                <input type="number" step="0.01" name="precio_venta" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Stock mínimo</label>
                <input type="number" name="stock_minimo" min="0" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Cantidad inicial</label>
                <input type="number" name="cantidad" min="0" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Imagen URL</label>
                <input type="text" name="imagen_url" class="form-control">
            </div>

            <div class="col-md-4">
                <label class="form-label">Ubicación</label>
                <select name="ubicacion" class="form-select" required>
                    <% for (Map<String,Object> u : ubicaciones) { %>
                        <option value="<%=u.get("id_ubicacion")%>">
                            Est:<%=u.get("estanteria")%> Col:<%=u.get("columna")%> Fila:<%=u.get("fila")%>
                        </option>
                    <% } %>
                </select>
            </div>

            <div class="col-12 mt-3">
                <button class="btn btn-success w-100">✔ Agregar Producto</button>
            </div>

        </form>

    </div>
</div>


<!-- =======================================================
     FORMULARIO AGREGAR UBICACIÓN
======================================================= -->
<div class="card shadow-sm border-info">

    <div class="card-header bg-info text-white">
        <h4 class="mb-0">Nueva Ubicación</h4>
    </div>

    <div class="card-body">

        <form method="post" class="row g-3">
            <input type="hidden" name="accion" value="agregarUbicacion">

            <div class="col-md-4">
                <label class="form-label">Estantería</label>
                <input type="number" name="estanteria" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Columna</label>
                <input type="text" name="columna" class="form-control" required>
            </div>

            <div class="col-md-4">
                <label class="form-label">Fila</label>
                <input type="number" name="fila" class="form-control" required>
            </div>

            <div class="col-12 mt-3">
                <button class="btn btn-primary w-100">➕ Crear Ubicación</button>
            </div>

        </form>

    </div>
</div>

<!-- =======================================================
     LISTADO DE PRODUCTOS
======================================================= -->

<h2 class="text-primary fw-bold mt-4">Listado de Productos</h2>

<div class="input-group mb-3 mt-3">
    <span class="input-group-text">Buscar</span>
    <input type="text" id="filtroProd" class="form-control" placeholder="Buscar producto...">
</div>

<div class="table-responsive">
<table class="table table-bordered table-striped table-hover align-middle" id="tablaProductos">

<thead class="table-dark">
<tr>
    <th>ID</th>
    <th>Código</th>
    <th>Nombre</th>
    <th>Marca</th>
    <th>Unidad</th>
    <th>Precio Venta</th>
    <th>Precio Compra</th>
    <th>Cantidad</th>
    <th>Stock Mínimo</th>
    <th>Ubicación</th>
    <th>Imagen</th>
    <th>Acciones</th>
</tr>
</thead>

<tbody>

<%
for (Map<String,Object> p : productos) {

    String id = p.get("id_producto").toString();

    List<Map<String,Object>> ub = QueryManager.select(
        "SELECT estanteria, columna, fila FROM tb_ubicacion WHERE id_ubicacion=" + p.get("id_ubicacion")
    );

    String ubic = ub.isEmpty()
            ? "Sin ubicación"
            : "Est:" + ub.get(0).get("estanteria") +
              " Col:" + ub.get(0).get("columna") +
              " Fila:" + ub.get(0).get("fila");
%>

<tr id="row_<%=id%>">

    <td><%=id%></td>
    <td><%=p.get("codigo_barra")%></td>
    <td><%=p.get("nombre")%></td>
    <td><%=p.get("marca")%></td>
    <td><%=p.get("unidad")%></td>
    <td>$<%=p.get("precio_venta")%></td>
    <td>$<%=p.get("precio_compra")%></td>
    <td><%=p.get("cantidad")%></td>
    <td><%=p.get("stock_minimo")%></td>
    <td><%=ubic%></td>
    <td><img class="img-mini" src="<%=p.get("imagen_url")%>" onerror="this.src='https://cdn-icons-png.flaticon.com/512/564/564619.png'"></td>

    <td>
        <button class="btn btn-warning btn-sm" onclick="editarProducto('<%=id%>')">✏ Editar</button>

        <form method="post" style="display:inline;">
            <input type="hidden" name="accion" value="eliminarProducto">
            <input type="hidden" name="id" value="<%=id%>">
            <button class="btn btn-danger btn-sm" onclick="return confirm('¿Desactivar producto?')">🗑</button>
        </form>
    </td>

</tr>

<!-- FILA EDITABLE -->
<tr id="edit_<%=id%>" style="display:none;" class="table-warning">

<form method="post">
<input type="hidden" name="accion" value="actualizarProducto">
<input type="hidden" name="id" value="<%=id%>">

    <td><b><%=id%></b></td>
    <td><input class="form-control" name="codigo_barra" value="<%=p.get("codigo_barra")%>"></td>
    <td><input class="form-control" name="nombre" value="<%=p.get("nombre")%>"></td>
    <td><input class="form-control" name="marca" value="<%=p.get("marca")%>"></td>
    <td><input class="form-control" name="unidad" value="<%=p.get("unidad")%>"></td>
    <td><input type="number" step="0.01" class="form-control" name="precio_venta" value="<%=p.get("precio_venta")%>"></td>
    <td><input class="form-control" value="<%=p.get("precio_compra")%>" disabled></td>
    <td><input class="form-control" name="cantidad" value="<%=p.get("cantidad")%>"></td>
    <td><input class="form-control" name="stock_minimo" value="<%=p.get("stock_minimo")%>"></td>
    <td><input class="form-control" value="<%=ubic%>" disabled></td>
    <td><input class="form-control" name="imagen_url" value="<%=p.get("imagen_url")%>"></td>

    <td>
        <button class="btn btn-success btn-sm">💾 Guardar</button>
        <button type="button" class="btn btn-secondary btn-sm" onclick="cancelarEdicion('<%=id%>')">❌</button>
    </td>

</form>

</tr>

<% } %>

</tbody>
</table>
</div>

</div>

<script>
function editarProducto(id){
    document.getElementById("row_" + id).style.display = "none";
    document.getElementById("edit_" + id).style.display = "table-row";
}

function cancelarEdicion(id){
    document.getElementById("row_" + id).style.display = "table-row";
    document.getElementById("edit_" + id).style.display = "none";
}

// BUSCADOR
document.getElementById("filtroProd").addEventListener("input", function(){
    let filtro = this.value.toLowerCase();
    let filas = document.querySelectorAll("#tablaProductos tbody tr");

    filas.forEach(f => {
        if (f.id.startsWith("edit_")) return;
        f.style.display = f.innerText.toLowerCase().includes(filtro) ? "" : "none";
    });
});
</script>

</body>
</html>
