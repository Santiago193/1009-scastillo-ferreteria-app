<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ferreteria.empresa.Empresa" %>

<!-- Obtener datos de la empresa -->
<jsp:useBean id="datosEmpresa" class="com.ferreteria.empresa.Empresa" scope="session" />

<!-- Bootstrap Icons -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.5/font/bootstrap-icons.css">

<footer class="bg-light border-top mt-5 py-4">

    <div class="container text-center">

        <!-- ============================
             REDES SOCIALES (si existen)
        ============================ -->
        <ul class="list-inline mb-3">

            <% if (datosEmpresa.getFacebook() != null && !datosEmpresa.getFacebook().isEmpty()) { %>
            <li class="list-inline-item mx-2">
                <a class="text-decoration-none text-primary fw-semibold"
                   href="<%= datosEmpresa.getFacebook() %>" target="_blank">
                    <i class="bi bi-facebook me-1"></i> Facebook
                </a>
            </li>
            <% } %>

            <% if (datosEmpresa.getInstagram() != null && !datosEmpresa.getInstagram().isEmpty()) { %>
            <li class="list-inline-item mx-2">
                <a class="text-decoration-none text-danger fw-semibold"
                   href="<%= datosEmpresa.getInstagram() %>" target="_blank">
                    <i class="bi bi-instagram me-1"></i> Instagram
                </a>
            </li>
            <% } %>

            <% if (datosEmpresa.getSitioWeb() != null && !datosEmpresa.getSitioWeb().isEmpty()) { %>
            <li class="list-inline-item mx-2">
                <a class="text-decoration-none text-secondary fw-semibold"
                   href="<%= datosEmpresa.getSitioWeb() %>" target="_blank">
                    <i class="bi bi-globe me-1"></i> Sitio Web
                </a>
            </li>
            <% } %>

        </ul>

        <!-- ============================
             INFORMACIÓN PÚBLICA
        ============================ -->
        <p class="text-muted small mb-0">
            © <%= java.time.Year.now() %> 
            <%= datosEmpresa.getNombre() != null ? datosEmpresa.getNombre() : "Mi Empresa" %> <br>
            Todos los derechos reservados.
        </p>

    </div>

</footer>

</main>
</body>
</html>
