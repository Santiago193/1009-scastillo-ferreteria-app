<%@ page language="java" 
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="com.ferreteria.empresa.Empresa" 
%>

<jsp:useBean id="empresa" class="com.ferreteria.empresa.Empresa" scope="application" />

<%
    // ================================================
    // ACTUALIZAR DATOS SI SE ENVÍA FORMULARIO
    // ================================================
    request.setCharacterEncoding("UTF-8");

    if ("POST".equalsIgnoreCase(request.getMethod())) {

        empresa.setNombre(request.getParameter("nombre"));
        empresa.setSlogan(request.getParameter("slogan"));
        empresa.setRuc(request.getParameter("ruc"));
        empresa.setCorreo(request.getParameter("correo"));
        empresa.setCorreoAlt(request.getParameter("correoAlt"));
        empresa.setTelefono1(request.getParameter("telefono1"));
        empresa.setTelefono2(request.getParameter("telefono2"));
        empresa.setDireccion(request.getParameter("direccion"));
        empresa.setCiudad(request.getParameter("ciudad"));
        empresa.setSitioWeb(request.getParameter("sitioWeb"));
        empresa.setLogoUrl(request.getParameter("logoUrl"));
        empresa.setDescripcion(request.getParameter("descripcion"));
        empresa.setFacebook(request.getParameter("facebook"));
        empresa.setInstagram(request.getParameter("instagram"));

        request.setAttribute("msg", "Datos actualizados correctamente.");
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Configuración de Empresa</title>

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</head>

<body class="bodygeneral">
<!-- MENÚ SUPERIOR -->
<jsp:include page="/head&foot/menuu.jsp" />

<main class="container py-4">

    <div class="text-center mb-4">
        <h1 class="fw-bold text-primary">Configuración de Empresa</h1>
        <p class="text-muted">Modifica aquí los datos generales de tu negocio</p>
    </div>

    <% if (request.getAttribute("msg") != null) { %>
        <div class="alert alert-success text-center fw-bold">
            <%= request.getAttribute("msg") %>
        </div>
    <% } %>

    <!-- CARD DEL FORMULARIO -->
    <div class="card shadow-sm border-primary">
        <div class="card-header bg-primary text-white">
            <h4 class="mb-0">Datos Generales</h4>
        </div>

        <div class="card-body">

            <form method="post" accept-charset="UTF-8" class="row g-3">

                <!-- NOMBRE -->
                <div class="col-md-6">
                    <label class="form-label">Nombre</label>
                    <input type="text" name="nombre" class="form-control"
                           value="<%= empresa.getNombre() %>">
                </div>

                <!-- SLOGAN -->
                <div class="col-md-6">
                    <label class="form-label">Slogan</label>
                    <input type="text" name="slogan" class="form-control"
                           value="<%= empresa.getSlogan() %>">
                </div>

                <!-- RUC -->
                <div class="col-md-4">
                    <label class="form-label">RUC</label>
                    <input type="text" name="ruc" class="form-control"
                           value="<%= empresa.getRuc() %>">
                </div>

                <!-- CORREOS -->
                <div class="col-md-4">
                    <label class="form-label">Correo</label>
                    <input type="email" name="correo" class="form-control"
                           value="<%= empresa.getCorreo() %>">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Correo alterno</label>
                    <input type="email" name="correoAlt" class="form-control"
                           value="<%= empresa.getCorreoAlt() %>">
                </div>

                <!-- TELÉFONOS -->
                <div class="col-md-6">
                    <label class="form-label">Teléfono 1</label>
                    <input type="text" name="telefono1" class="form-control"
                           value="<%= empresa.getTelefono1() %>">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Teléfono 2</label>
                    <input type="text" name="telefono2" class="form-control"
                           value="<%= empresa.getTelefono2() %>">
                </div>

                <!-- DIRECCIÓN -->
                <div class="col-md-8">
                    <label class="form-label">Dirección</label>
                    <input type="text" name="direccion" class="form-control"
                           value="<%= empresa.getDireccion() %>">
                </div>

                <div class="col-md-4">
                    <label class="form-label">Ciudad</label>
                    <input type="text" name="ciudad" class="form-control"
                           value="<%= empresa.getCiudad() %>">
                </div>

                <!-- SITIO WEB -->
                <div class="col-md-6">
                    <label class="form-label">Sitio Web</label>
                    <input type="text" name="sitioWeb" class="form-control"
                           value="<%= empresa.getSitioWeb() %>">
                </div>

                <!-- LOGO -->
                <div class="col-md-6">
                    <label class="form-label">Logo URL</label>
                    <input type="text" name="logoUrl" class="form-control"
                           value="<%= empresa.getLogoUrl() %>">
                </div>

                <!-- DESCRIPCIÓN -->
                <div class="col-md-12">
                    <label class="form-label">Descripción</label>
                    <textarea name="descripcion" class="form-control" rows="3"><%= empresa.getDescripcion() %></textarea>
                </div>

                <!-- REDES -->
                <div class="col-md-6">
                    <label class="form-label">Facebook</label>
                    <input type="text" name="facebook" class="form-control"
                           value="<%= empresa.getFacebook() %>">
                </div>

                <div class="col-md-6">
                    <label class="form-label">Instagram</label>
                    <input type="text" name="instagram" class="form-control"
                           value="<%= empresa.getInstagram() %>">
                </div>

                <!-- BOTÓN GUARDAR -->
                <div class="col-12 text-center mt-3">
                    <button type="submit" class="btn btn-success px-5 fw-bold">
                        💾 Guardar cambios
                    </button>
                </div>

            </form>
        </div>
    </div>

</main>

</body>
</html>
