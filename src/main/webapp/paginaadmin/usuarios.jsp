<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.util.*, com.ferreteria.seguridad.Usuario" %>

<%
    request.setCharacterEncoding("UTF-8");

    String filtroNombre = request.getParameter("buscar")==null?"":request.getParameter("buscar");
    String filtroPerfil = request.getParameter("tipo");
    int perfilFiltro = (filtroPerfil == null || filtroPerfil.equals("")) ? 0 : Integer.parseInt(filtroPerfil);

    List<Usuario> lista = Usuario.buscar(filtroNombre, perfilFiltro);

    // GUARDAR EDICIÓN
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("editarId") != null) {

        int id = Integer.parseInt(request.getParameter("editarId"));
        Usuario u = Usuario.obtenerPorId(id);

        u.setNombre(request.getParameter("nombre"));
        u.setApellido(request.getParameter("apellido"));
        u.setCorreo(request.getParameter("correo"));
        u.setContrasena(request.getParameter("clave"));
        u.setId_perfil(Integer.parseInt(request.getParameter("perfil")));
        u.setBloqueado("on".equals(request.getParameter("bloqueado")));

        u.actualizar();
        response.sendRedirect("usuarios.jsp");
        return;
    }

    // AGREGAR USUARIO
    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("agregar") != null) {

        Usuario u = new Usuario();
        u.setNombre(request.getParameter("nombre"));
        u.setApellido(request.getParameter("apellido"));
        u.setCorreo(request.getParameter("correo"));
        u.setContrasena(request.getParameter("clave"));
        u.setId_perfil(Integer.parseInt(request.getParameter("perfil")));
        u.setId_estadocivil(1);

        u.agregarAdmin();
        response.sendRedirect("usuarios.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Gestión de Usuarios</title>

<!-- BOOTSTRAP -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<script>
function editarFila(id) {
    document.querySelectorAll(".fila-" + id).forEach(e => {
        e.classList.add("table-warning");
        e.querySelectorAll("span").forEach(s=>s.style.display="none");
        e.querySelectorAll("input, select").forEach(i=>i.style.display="inline-block");
    });

    document.getElementById("btn-editar-"+id).style.display="none";
    document.getElementById("guardar-"+id).style.display="inline-block";
    document.getElementById("cancelar-"+id).style.display="inline-block";
}

function cancelarFila(id){
    location.reload();
}
</script>

</head>

<body class="bodygeneral">
<jsp:include page="/head&foot/menuu.jsp" />

<div class="container py-4">

<h2 class="fw-bold text-primary mb-4">Gestión de Usuarios</h2>


<!-- =============================== -->
<!-- FORMULARIO AGREGAR -->
<!-- =============================== -->
<div class="card shadow-sm mb-4">
    <div class="card-header bg-primary text-white fw-bold">Agregar Usuario</div>

    <div class="card-body">

        <form method="post" class="row g-3">
            <input type="hidden" name="agregar" value="1">

            <div class="col-md-4">
                <input type="text" name="nombre" class="form-control" placeholder="Nombre" required>
            </div>

            <div class="col-md-4">
                <input type="text" name="apellido" class="form-control" placeholder="Apellido" required>
            </div>

            <div class="col-md-4">
                <input type="email" name="correo" class="form-control" placeholder="Correo" required>
            </div>

            <div class="col-md-4">
                <input type="password" name="clave" class="form-control" placeholder="Contraseña" required>
            </div>

            <div class="col-md-4">
                <select name="perfil" class="form-select">
                    <option value="1">ADMIN</option>
                    <option value="2">EMPLEADO</option>
                    <option value="3">USUARIO</option>
                </select>
            </div>

            <div class="col-12">
                <button type="submit" class="btn btn-success w-100">✔ Agregar Usuario</button>
            </div>

        </form>

    </div>
</div>


<!-- =============================== -->
<!-- FORMULARIO DE BÚSQUEDA -->
<!-- =============================== -->
<div class="card shadow-sm mb-4">
    <div class="card-header bg-info text-white fw-bold">Buscar / Filtrar Usuarios</div>

    <div class="card-body">

        <form method="get" class="row g-3">

            <div class="col-md-6">
                <input type="text" name="buscar" class="form-control"
                       placeholder="Buscar por nombre" value="<%= filtroNombre %>">
            </div>

            <div class="col-md-4">
                <select name="tipo" class="form-select">
                    <option value="">Todos</option>
                    <option value="1" <%= "1".equals(filtroPerfil)?"selected":"" %>>Admin</option>
                    <option value="2" <%= "2".equals(filtroPerfil)?"selected":"" %>>Empleado</option>
                    <option value="3" <%= "3".equals(filtroPerfil)?"selected":"" %>>Usuario</option>
                </select>
            </div>

            <div class="col-md-2">
                <button type="submit" class="btn btn-primary w-100">Filtrar</button>
            </div>

        </form>

    </div>
</div>


<!-- =============================== -->
<!-- TABLA DE USUARIOS -->
<!-- =============================== -->
<h3 class="fw-bold text-secondary mb-3">Usuarios Registrados</h3>

<div class="table-responsive">
<table class="table table-striped table-hover table-bordered">

<thead class="table-dark">
<tr>
    <th>ID</th>
    <th>Nombre</th>
    <th>Correo</th>
    <th>Contraseña</th>
    <th>Perfil</th>
    <th>Estado</th>
    <th>Acciones</th>
</tr>
</thead>

<tbody>
<% for (Usuario u : lista) { %>

<form method="post">

<tr class="fila-<%= u.getId_usuario() %>">

    <td>
        <%= u.getId_usuario() %>
        <input type="hidden" name="editarId" value="<%= u.getId_usuario() %>">
    </td>

    <!-- Nombre y apellido -->
    <td>
        <span><%= u.getNombre() %> <%= u.getApellido() %></span>

        <input type="text" name="nombre" value="<%= u.getNombre() %>"
               class="form-control" style="display:none; width:130px;">
        <input type="text" name="apellido" value="<%= u.getApellido() %>"
               class="form-control" style="display:none; width:130px;">
    </td>

    <!-- Correo -->
    <td>
        <span><%= u.getCorreo() %></span>
        <input type="text" name="correo" value="<%= u.getCorreo() %>"
               class="form-control" style="display:none;">
    </td>

    <!-- Contraseña -->
    <td>
        <span>••••••</span>
        <input type="text" name="clave" value="<%= u.getContrasena() %>"
               class="form-control" style="display:none;">
    </td>

    <!-- Perfil -->
    <td>
        <span><%= u.getId_perfil()==1?"ADMIN": u.getId_perfil()==2?"EMPLEADO":"USUARIO" %></span>

        <select name="perfil" class="form-select" style="display:none;">
            <option value="1" <%= u.getId_perfil()==1?"selected":"" %>>ADMIN</option>
            <option value="2" <%= u.getId_perfil()==2?"selected":"" %>>EMPLEADO</option>
            <option value="3" <%= u.getId_perfil()==3?"selected":"" %>>USUARIO</option>
        </select>
    </td>

    <!-- Estado -->
    <td>
        <span><%= u.isBloqueado() ? "Bloqueado" : "Activo" %></span>
        <input type="checkbox" name="bloqueado"
               <%= u.isBloqueado() ? "checked" : "" %>
               style="display:none;">
    </td>

    <!-- ACCIONES -->
    <td>

        <button type="button" id="btn-editar-<%= u.getId_usuario() %>"
                class="btn btn-warning btn-sm"
                onclick="editarFila(<%= u.getId_usuario() %>)">
            Editar
        </button>

        <button type="submit" id="guardar-<%= u.getId_usuario() %>"
                class="btn btn-success btn-sm" style="display:none;">
            Guardar
        </button>

        <button type="button" id="cancelar-<%= u.getId_usuario() %>"
                class="btn btn-secondary btn-sm" style="display:none;"
                onclick="cancelarFila(<%= u.getId_usuario() %>)">
            Cancelar
        </button>

        <button type="submit" name="eliminarId"
                value="<%= u.getId_usuario() %>"
                onclick="return confirm('¿Eliminar este usuario?')"
                class="btn btn-danger btn-sm">
            Eliminar
        </button>

    </td>

</tr>
</form>

<% } %>
</tbody>
</table>
</div>

</div>
</body>
</html>
