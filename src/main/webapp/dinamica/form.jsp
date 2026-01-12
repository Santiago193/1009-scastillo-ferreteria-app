<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="com.ferreteria.datos.QueryManager, java.util.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    String titulo = request.getParameter("tituloForm");
    String tabla  = request.getParameter("tabla");
    String redirect = request.getParameter("redirect");
    String rawCampos = request.getParameter("campos");

    // Parseo simple JSON → Map<String,String>
    Map<String,String> campos = new LinkedHashMap<>();

    if (rawCampos != null && !rawCampos.isEmpty()) {
        rawCampos = rawCampos.replace("{", "").replace("}", "").replace("\"", "");
        String[] partes = rawCampos.split(",");
        for (String p : partes) {
            String[] kv = p.split(":");
            if (kv.length == 2)
                campos.put(kv[0].trim(), kv[1].trim());
        }
    }

    // ACCIÓN GUARDAR
    if ("insertar".equals(request.getParameter("accion"))) {

        StringBuilder columnas = new StringBuilder("(");
        StringBuilder valores  = new StringBuilder("(");

        for (Map.Entry<String,String> e : campos.entrySet()) {
            String col = e.getKey();
            String val = request.getParameter(col);

            columnas.append(col).append(",");
            valores.append("'").append(val).append("',");
        }

        columnas.setLength(columnas.length()-1);
        valores.setLength(valores.length()-1);
        columnas.append(")");
        valores.append(")");

        String sqlInsert = "INSERT INTO " + tabla + " " + columnas + " VALUES " + valores;
        QueryManager.update(sqlInsert);

        if (redirect != null)
            response.sendRedirect(redirect);

        return;
    }
%>

<!-- ===== BOOTSTRAP ===== -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">


<!-- =============== FORMULARIO TARJETA ================= -->
<div class="card shadow-sm mb-4">

    <div class="card-header bg-primary text-white">
        <h4 class="mb-0"><%= titulo %></h4>
    </div>

    <div class="card-body">

        <form method="post">
            <input type="hidden" name="accion" value="insertar">

            <div class="row g-3">

                <% for (Map.Entry<String,String> e : campos.entrySet()) { %>

                    <div class="col-md-6">
                        <label class="form-label fw-semibold">
                            <%= e.getKey() %>
                        </label>

                        <input type="<%= e.getValue() %>"
                               name="<%= e.getKey() %>"
                               class="form-control"
                               required>
                    </div>

                <% } %>

            </div>

            <div class="mt-4">
                <button class="btn btn-primary w-100">
                    💾 Guardar
                </button>
            </div>

        </form>

    </div>
</div>
