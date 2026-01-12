<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" session="true" import="com.ferreteria.seguridad.*" %>

<%
Usuario usuario = new Usuario();

String nlogin = request.getParameter("usuario");
String nclave = request.getParameter("clave");

boolean respuesta = usuario.verificarUsuario(nlogin, nclave);

// PRIMERO verificar si está bloqueado
if (usuario.isBloqueado()) {
%>
    <jsp:forward page="login.jsp">
        <jsp:param name="error" value="Tu cuenta está BLOQUEADA. Contacte al administrador." />
    </jsp:forward>
<%
    return;
}

// ----------------------
// ⚠️ ESTA LÍNEA FALTABA
// ----------------------
HttpSession sesion = request.getSession();

// Si usuario y clave correctos
if (respuesta) {

    sesion.setAttribute("usuario", usuario.getNombre());
    sesion.setAttribute("perfil", usuario.getId_perfil());
    session.setAttribute("id", usuario.getId_usuario());
    session.setAttribute("id_usuario", usuario.getId_usuario());


    response.sendRedirect("menu.jsp");

} else {
%>
    <jsp:forward page="login.jsp">
        <jsp:param name="error" value="Datos incorrectos.<br/>Vuelva a intentarlo."/>
    </jsp:forward>
<%
}
%>
