<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="
        java.util.*,
        com.ferreteria.admin.Proveedor,
        com.ferreteria.admin.Producto,
        com.ferreteria.admin.Compra,
        com.ferreteria.datos.QueryManager
    "
%>

<%
    request.setCharacterEncoding("UTF-8");

    /* ==========================================================
       ACCIÓN: REGISTRAR COMPRA
    ========================================================== */
    if ("registrarCompra".equals(request.getParameter("accion"))) {

        int proveedor = Integer.parseInt(request.getParameter("proveedor"));
        int producto  = Integer.parseInt(request.getParameter("producto"));
        int cantidad  = Integer.parseInt(request.getParameter("cantidad"));
        double precio = Double.parseDouble(request.getParameter("precio"));

        Compra.registrar(proveedor, producto, cantidad, precio);

        response.sendRedirect("compras.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: REGISTRAR PROVEEDOR
    ========================================================== */
    if ("registrarProveedor".equals(request.getParameter("accion"))) {

        String nombre    = request.getParameter("nombre");
        String telefono  = request.getParameter("telefono");
        String correo    = request.getParameter("correo");
        String ubicacion = request.getParameter("ubicacion");

        String sql = "INSERT INTO tb_proveedor (nombre, telefono, correo, ubicacion) VALUES (" +
                     "'" + nombre + "','" + telefono + "','" + correo + "','" + ubicacion + "')";

        QueryManager.update(sql);
        response.sendRedirect("compras.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: ELIMINAR COMPRA COMPLETA
    ========================================================== */
    if ("eliminarCompra".equals(request.getParameter("accion"))) {

        String idc = request.getParameter("id_compra");

        QueryManager.update("DELETE FROM tb_compra WHERE id_compra = " + idc);

        response.sendRedirect("compras.jsp");
        return;
    }

    /* ==========================================================
       ACCIÓN: EDITAR DETALLE DE COMPRA
    ========================================================== */
    if ("editarDetalle".equals(request.getParameter("accion"))) {

        int idDetalle = Integer.parseInt(request.getParameter("id_detalle"));
        int cantidad  = Integer.parseInt(request.getParameter("cantidad"));
        double precio = Double.parseDouble(request.getParameter("precio_compra"));

        String sql = "UPDATE tb_compra_detalle SET cantidad=" + cantidad +
                     ", precio_compra=" + precio +
                     " WHERE id_detalle=" + idDetalle;

        QueryManager.update(sql);

        response.sendRedirect("compras.jsp");
        return;
    }

    /* ==========================================================
       LISTAS
    ========================================================== */
    List<Proveedor> proveedores = Proveedor.listar();

    // SOLO PRODUCTOS ACTIVOS
    List<Map<String,Object>> productos = QueryManager.select(
        "SELECT * FROM tb_producto WHERE activo=true ORDER BY nombre"
    );

    List<Map<String,Object>> historial = QueryManager.select(
        "SELECT c.id_compra, d.id_detalle, pr.nombre AS proveedor, p.nombre AS producto, " +
        "d.cantidad, d.precio_compra, c.fecha " +
        "FROM tb_compra c " +
        "JOIN tb_compra_detalle d ON d.id_compra=c.id_compra " +
        "JOIN tb_producto p ON p.id_producto=d.id_producto " +
        "JOIN tb_proveedor pr ON pr.id_proveedor=c.id_proveedor " +
        "ORDER BY c.id_compra DESC"
    );
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Compras</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<style>
.edit-row { background:#fff3cd; }
</style>
</head>

<body class="bodygeneral">

<jsp:include page="../head&foot/menuu.jsp" />

<div class="container py-4">

<!-- =======================================================
     FORMULARIO PARA REGISTRO DE COMPRA
======================================================= -->
<div class="card shadow-sm border-primary mb-4">
    <div class="card-header bg-primary text-white"><h4>Registrar Compra</h4></div>

    <div class="card-body">

        <form method="post" class="row g-3">
            <input type="hidden" name="accion" value="registrarCompra">

            <!-- PROVEEDOR -->
            <div class="col-md-6">
                <label class="form-label">Proveedor</label>
                <input type="text" id="buscarProveedor" class="form-control mb-1" placeholder="Buscar proveedor...">

                <select name="proveedor" id="proveedor" class="form-select" required>
                    <% for (Proveedor p : proveedores) { %>
                        <option value="<%=p.getId()%>"><%=p.getNombre()%></option>
                    <% } %>
                </select>
            </div>

            <!-- PRODUCTO -->
            <div class="col-md-6">
                <label class="form-label">Producto</label>
                <input type="text" id="buscarProducto" class="form-control mb-1" placeholder="Buscar producto...">

                <select name="producto" id="producto" class="form-select" required>
                    <% for (Map<String,Object> pr : productos) { %>
                        <option value="<%=pr.get("id_producto")%>">
                            <%=pr.get("nombre")%> | Cod:<%=pr.get("codigo_barra")%>
                        </option>
                    <% } %>
                </select>
            </div>

            <!-- PRECIO -->
            <div class="col-md-4">
                <label class="form-label">Precio Compra</label>
                <input type="number" name="precio" id="precio" step="0.01" class="form-control" required>
            </div>

            <!-- CANTIDAD -->
            <div class="col-md-4">
                <label class="form-label">Cantidad</label>
                <input type="number" name="cantidad" id="cantidad" min="1" class="form-control" required>
            </div>

            <!-- TOTAL -->
            <div class="col-md-4">
                <label class="form-label">Total</label>
                <input type="text" id="total" class="form-control bg-light" readonly>
            </div>

            <div class="col-12 mt-3">
                <button class="btn btn-success w-100">✔ Registrar Compra</button>
            </div>

        </form>

    </div>
</div>

<!-- =======================================================
     FORMULARIO NUEVO PROVEEDOR
======================================================= -->
<div class="card shadow-sm border-info mb-4">
    <div class="card-header bg-info text-white"><h5>Registrar Nuevo Proveedor</h5></div>

    <div class="card-body">
        <form method="post" class="row g-3">
            <input type="hidden" name="accion" value="registrarProveedor">

            <div class="col-md-6">
                <label class="form-label">Nombre</label>
                <input type="text" name="nombre" class="form-control" required>
            </div>

            <div class="col-md-3">
                <label class="form-label">Teléfono</label>
                <input type="text" name="telefono" class="form-control">
            </div>

            <div class="col-md-3">
                <label class="form-label">Correo</label>
                <input type="email" name="correo" class="form-control">
            </div>

            <div class="col-md-12">
                <label class="form-label">Ubicación</label>
                <input type="text" name="ubicacion" class="form-control">
            </div>

            <div class="col-12">
                <button class="btn btn-primary w-100">➕ Registrar Proveedor</button>
            </div>
        </form>
    </div>
</div>

<!-- =======================================================
     HISTORIAL DE COMPRAS CON EDICIÓN Y ELIMINACIÓN
======================================================= -->
<div class="card shadow-sm border-warning">
    <div class="card-header bg-warning"><h5>Historial de Compras</h5></div>
    <div class="card-body">

<table class="table table-bordered table-striped">
<thead class="table-dark">
<tr>
    <th>ID Compra</th>
    <th>Proveedor</th>
    <th>Producto</th>
    <th>Cantidad</th>
    <th>Precio</th>
    <th>Fecha</th>
    <th>Acciones</th>
</tr>
</thead>
<tbody>

<%
for (Map<String,Object> h : historial) {
    String idc  = h.get("id_compra").toString();
    String idd  = h.get("id_detalle").toString();
%>

<tr id="row_<%=idd%>">
    <td><%=idc%></td>
    <td><%=h.get("proveedor")%></td>
    <td><%=h.get("producto")%></td>
    <td><%=h.get("cantidad")%></td>
    <td>$<%=h.get("precio_compra")%></td>
    <td><%=h.get("fecha")%></td>

    <td>
        <button onclick="editar(<%=idd%>)" class="btn btn-warning btn-sm">✏ Editar</button>

        <form method="post" style="display:inline;">
            <input type="hidden" name="accion" value="eliminarCompra">
            <input type="hidden" name="id_compra" value="<%=idc%>">
            <button onclick="return confirm('¿Eliminar compra completa?')" class="btn btn-danger btn-sm">🗑</button>
        </form>
    </td>
</tr>

<!-- FILA EDITAR -->
<tr id="edit_<%=idd%>" class="edit-row" style="display:none;">
<form method="post">
    <input type="hidden" name="accion" value="editarDetalle">
    <input type="hidden" name="id_detalle" value="<%=idd%>">

    <td><%=idc%></td>
    <td><%=h.get("proveedor")%></td>
    <td><%=h.get("producto")%></td>
    <td><input type="number" min="1" name="cantidad" class="form-control" value="<%=h.get("cantidad")%>"></td>
    <td><input type="number" step="0.01" name="precio_compra" class="form-control" value="<%=h.get("precio_compra")%>"></td>
    <td><%=h.get("fecha")%></td>

    <td>
        <button class="btn btn-success btn-sm">💾 Guardar</button>
        <button type="button" onclick="cancelar(<%=idd%>)" class="btn btn-secondary btn-sm">❌</button>
    </td>
</form>
</tr>

<% } %>

</tbody>
</table>

    </div>
</div>

</div>

<!-- =======================================================
     JS – BÚSQUEDAS Y EDICIÓN
======================================================= -->
<script>
function editar(id){
    document.getElementById("row_" + id).style.display = "none";
    document.getElementById("edit_" + id).style.display = "table-row";
}
function cancelar(id){
    document.getElementById("row_" + id).style.display = "table-row";
    document.getElementById("edit_" + id).style.display = "none";
}

// BUSCAR PROVEEDOR
document.getElementById("buscarProveedor").addEventListener("input", function(){
    let f = this.value.toLowerCase();
    for (let o of document.getElementById("proveedor").options)
        o.style.display = o.textContent.toLowerCase().includes(f) ? "" : "none";
});

// BUSCAR PRODUCTO
document.getElementById("buscarProducto").addEventListener("input", function(){
    let f = this.value.toLowerCase();
    for (let o of document.getElementById("producto").options)
        o.style.display = o.textContent.toLowerCase().includes(f) ? "" : "none";
});

// CALCULAR TOTAL
function actualizarTotal(){
    let c = parseFloat(document.getElementById("cantidad").value) || 0;
    let p = parseFloat(document.getElementById("precio").value) || 0;
    document.getElementById("total").value = (c * p).toFixed(2);
}
document.getElementById("cantidad").oninput = actualizarTotal;
document.getElementById("precio").oninput = actualizarTotal;
</script>

</body>
</html>
