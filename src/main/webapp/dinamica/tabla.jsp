<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.*, com.ferreteria.datos.QueryManager" %>

<%
    request.setCharacterEncoding("UTF-8");

    // ==============================
    // PARAMETROS RECIBIDOS
    // ==============================
    String sql = request.getParameter("sql");
    String titulo = request.getParameter("tituloTabla");
    String tablaBase = request.getParameter("tablaBase");
    String jsonRaw = request.getParameter("tablasColumnas");

    Map<String,String> columnaTabla = new HashMap<>();

    if (jsonRaw != null && !jsonRaw.trim().equals("")) {
        jsonRaw = jsonRaw.trim().replace("{","").replace("}","").replace("\"","");
        for (String par : jsonRaw.split(",")) {
            String[] kv = par.split(":");
            if (kv.length == 2)
                columnaTabla.put(kv[0].trim(), kv[1].trim());
        }
    }

    Map<String,String> primaryKeys = new HashMap<>();
    primaryKeys.put("tb_compra","id_compra");
    primaryKeys.put("tb_compra_detalle","id_detalle");
    primaryKeys.put("tb_producto","id_producto");
    primaryKeys.put("tb_proveedor","id_proveedor");
    primaryKeys.put("tb_producto_proveedor","id");
    primaryKeys.put("tb_venta","id_venta");
    primaryKeys.put("tb_venta_detalle","id_detalle");
    primaryKeys.put("tb_usuario","id_usuario");
    primaryKeys.put("tb_ubicacion","id_ubicacion");

    // ==============================
    // ACCIÓN UPDATE
    // ==============================
    if ("actualizar".equals(request.getParameter("accion"))) {

        String idBase = request.getParameter("idBase");

        Map<String,Map<String,String>> updatePorTabla = new HashMap<>();

        Enumeration<String> params = request.getParameterNames();
        while (params.hasMoreElements()) {

            String param = params.nextElement();

            if (param.equals("accion") || param.equals("sql") || param.equals("tituloTabla")
               || param.equals("idBase") || param.equals("tablaBase")
               || param.equals("tablasColumnas")) continue;

            String tablaReal = columnaTabla.get(param);
            if (tablaReal == null) continue;

            updatePorTabla.putIfAbsent(tablaReal, new HashMap<>());
            updatePorTabla.get(tablaReal).put(param, request.getParameter(param));
        }

        for (String tabla : updatePorTabla.keySet()) {

            Map<String,String> cols = updatePorTabla.get(tabla);

            StringBuilder q = new StringBuilder("UPDATE " + tabla + " SET ");
            for (String c : cols.keySet()) {
                q.append(c).append("='").append(cols.get(c)).append("', ");
            }
            q.setLength(q.length() - 2);

            String pk = primaryKeys.get(tabla);
            q.append(" WHERE ").append(pk).append("=").append(idBase);

            QueryManager.update(q.toString());
        }
    }

    // ==============================
    // ACCIÓN DELETE
    // ==============================
    if ("eliminar".equals(request.getParameter("accion"))) {

        String idBase = request.getParameter("idBase");
        String pk = primaryKeys.get(tablaBase);

        String q = "DELETE FROM " + tablaBase + " WHERE " + pk + "=" + idBase;
        QueryManager.update(q);
    }

    // ==============================
    // CONSULTA PRINCIPAL
    // ==============================
    List<Map<String,Object>> datos = QueryManager.select(sql);

    if (datos.isEmpty()) {
        out.println("<div class='alert alert-info text-center mt-3'>No hay resultados</div>");
        return;
    }

    Map<String,Object> ejemplo = datos.get(0);
    Set<String> columnas = ejemplo.keySet();
%>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<h3 class="mt-4 mb-3 text-primary fw-bold"><%= titulo %></h3>

<!-- ==============================
     BUSCADOR
============================== -->
<div class="mb-3">
    <input type="text" id="filtroTabla" class="form-control" placeholder="Buscar en la tabla...">
</div>

<div class="table-responsive">
<table class="table table-bordered table-hover align-middle shadow-sm">
<thead class="table-dark">
<tr>
    <% for (String col : columnas) { %>
        <th><%= col %></th>
    <% } %>
    <th class="text-center">Acciones</th>
</tr>
</thead>

<tbody>

<%
for (Map<String,Object> fila : datos) {

    String idBase = fila.get(columnas.iterator().next()).toString();
%>

<!-- ==============================
     FILA NORMAL
============================== -->
<tr id="f_<%= idBase %>">

    <% for (String col : columnas) { %>
        <td><%= fila.get(col) %></td>
    <% } %>

    <td class="text-center">

        <!-- EDITAR -->
        <button class="btn btn-sm btn-warning" onclick="editar('<%= idBase %>')">
            ✏️ Editar
        </button>

        <!-- ELIMINAR -->
        <form method="post" class="d-inline">
            <input type="hidden" name="accion" value="eliminar">
            <input type="hidden" name="idBase" value="<%= idBase %>">
            <input type="hidden" name="tablaBase" value="<%= tablaBase %>">
            <input type="hidden" name="sql" value="<%= sql %>">
            <input type="hidden" name="tituloTabla" value="<%= titulo %>">
            <input type="hidden" name="tablasColumnas" value="<%= request.getParameter("tablasColumnas") %>">

            <button class="btn btn-sm btn-danger"
                    onclick="return confirm('¿Eliminar registro?')">
                🗑 Eliminar
            </button>
        </form>

    </td>
</tr>

<!-- ==============================
     FILA EDITABLE
============================== -->
<form method="post">
<tr id="e_<%= idBase %>" class="table-info" style="display:none;">

    <input type="hidden" name="accion" value="actualizar">
    <input type="hidden" name="idBase" value="<%= idBase %>">
    <input type="hidden" name="tablaBase" value="<%= tablaBase %>">
    <input type="hidden" name="sql" value="<%= sql %>">
    <input type="hidden" name="tituloTabla" value="<%= titulo %>">
    <input type="hidden" name="tablasColumnas" value="<%= request.getParameter("tablasColumnas") %>">

    <%
        boolean first = true;
        for (String col : columnas) {
    %>

    <td>
        <% if (first) { %>
            <b><%= fila.get(col) %></b>
            <input type="hidden" name="<%= col %>" value="<%= fila.get(col) %>">
            <% first = false; %>
        <% } else { %>
            <input type="text" name="<%= col %>" class="form-control"
                   value="<%= fila.get(col) %>">
        <% } %>
    </td>

    <% } %>

    <td class="text-center">

        <button class="btn btn-success btn-sm">💾 Guardar</button>

        <button type="button" class="btn btn-secondary btn-sm"
                onclick="cancelar('<%= idBase %>')">
            ❌ Cancelar
        </button>

    </td>
</tr>
</form>

<% } %>

</tbody>
</table>
</div>

<script>
// Mostrar fila editable
function editar(id){
    document.getElementById("f_"+id).style.display = "none";
    document.getElementById("e_"+id).style.display = "table-row";
}

// Cancelar edición
function cancelar(id){
    document.getElementById("f_"+id).style.display = "table-row";
    document.getElementById("e_"+id).style.display = "none";
}

// Buscador universal
document.getElementById("filtroTabla").addEventListener("input", function () {

    let filtro = this.value.toLowerCase();
    let filas = document.querySelectorAll("tbody tr");

    filas.forEach(fila => {
        if (fila.id.startsWith("e_")) return;

        let texto = fila.innerText.toLowerCase();
        fila.style.display = texto.includes(filtro) ? "" : "none";
    });
});
</script>
