<%@ page language="java" 
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    session="true"
    import="com.ferreteria.seguridad.*, java.time.*, java.time.format.*" %>

<%
    // ===== Validación de sesión =====
    HttpSession sesion = request.getSession();

    if (sesion.getAttribute("usuario") == null) {
%>
    <jsp:forward page="../login.jsp">
        <jsp:param name="error" value="Debe iniciar sesión para continuar." />
    </jsp:forward>
<%
        return;
    }

    String usuario = (String) sesion.getAttribute("usuario");
    Integer perfil = (Integer) sesion.getAttribute("perfil");
    if (perfil == null) perfil = 0;

    // Menú dinámico generado desde tu clase Pagina
    Pagina pag = new Pagina();
    String menu = pag.mostrarMenu(perfil);

    // Fecha y hora
    LocalDateTime ahora = LocalDateTime.now();
    DateTimeFormatter formatoFecha = DateTimeFormatter.ofPattern("EEEE, dd 'de' MMMM yyyy");
    DateTimeFormatter formatoHora = DateTimeFormatter.ofPattern("hh:mm a");

    String fecha = ahora.format(formatoFecha);
    String hora  = ahora.format(formatoHora);
%>

<!-- ================================
     BOOTSTRAP
================================ -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<link rel="stylesheet" href="../general/general.css"> <!-- Fondo lila -->

<!-- ================================
     ESTILOS MEJORADOS
================================ -->
<style>

/* PANEL ENCABEZADO */
.panel-header {
    background: linear-gradient(135deg, #7E57C2, #9575CD);
    color: white;
    padding: 35px;
    border-radius: 18px;
    text-align: center;
    box-shadow: 0px 6px 15px rgba(0,0,0,0.18);
}
.panel-header h1 {
    font-weight: 800;
    letter-spacing: 1px;
}
.panel-header h4 {
    font-weight: 400;
    color: #f3eaff;
}

/* CONTENEDOR DEL MENÚ (glassmorphism) */
.menu-wrapper {
    background: rgba(255, 255, 255, 0.30);
    backdrop-filter: blur(10px);
    border-radius: 18px;
    padding: 25px;
    box-shadow: 0px 8px 20px rgba(0,0,0,0.12);
    border: 1px solid rgba(255,255,255,0.35);
}

/* BOTONES DEL MENÚ */
.menu-container a,
.menu-container button {
    background: #7E57C2 !important;
    color: white !important;
    padding: 12px 25px;
    border-radius: 12px;
    border: none !important;
    font-weight: 600;
    text-decoration: none;
    font-size: 15px;
    display: inline-block;
    transition: 0.2s ease-in-out;
    box-shadow: 0 4px 8px rgba(0,0,0,0.18);
}

.menu-container a:hover,
.menu-container button:hover {
    background: #5E35B1 !important;
    transform: translateY(-3px);
    box-shadow: 0 6px 12px rgba(0,0,0,0.22);
}

.menu-container a:active {
    background: #512DA8 !important;
    transform: scale(0.96);
}

/* TARJETA DE FECHA / HORA */
.time-card {
    background: #EDE7F6;
    border-left: 6px solid #7E57C2;
    border-radius: 12px;
    padding: 15px 20px;
    box-shadow: 0px 4px 12px rgba(0,0,0,0.10);
}

</style>

<!-- ================================
     PANEL PRINCIPAL
================================ -->
<div class="container py-4">

    <!-- ENCABEZADO -->
    <div class="panel-header mb-4">
        <h1>🔧 Panel de Gestión – Ferretería</h1>
        <h4>👋 Bienvenido, <b><%= usuario %></b></h4>
    </div>

    <!-- MENÚ DISEÑO MODERNO -->
    <div class="menu-wrapper mb-4">
        <div class="menu-container d-flex justify-content-center flex-wrap gap-3">
            <%= menu %>
        </div>
    </div>

    <!-- FECHA / HORA -->
    <div class="time-card shadow-sm">
        <div class="d-flex justify-content-between">
            <span><b>📅 Fecha:</b> <%= fecha %></span>
            <span><b>⏰ Hora:</b> <%= hora %></span>
        </div>
    </div>

</div>

</body>
</html>
