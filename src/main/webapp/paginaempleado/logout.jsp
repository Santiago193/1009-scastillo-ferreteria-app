<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" session="true"%>

<%
    HttpSession sesionOk = request.getSession(false);
    if (sesionOk != null) {
        sesionOk.invalidate(); // eliminar sesión
    }

    // Redirigir correctamente al login recargando CSS, imágenes, JSP, TODO
    response.sendRedirect(request.getContextPath() + "/login.jsp");
%>
