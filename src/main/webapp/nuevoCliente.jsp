<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8" import="com.ferreteria.seguridad.*"%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Pesebre Navideño</title>
<link rel="stylesheet" href="css/general.css">
<link rel="stylesheet" href="css/index.css">
<script type="module"
	src="https://ajax.googleapis.com/ajax/libs/model-viewer/4.0.0/model-viewer.min.js">
</script>
</head>
<body class="bodygeneral">
<jsp:include page="head&foot/head.jsp" />
<%
// ====== 1️⃣ Capturar datos del formulario REAL ======
String nombre = request.getParameter("txtNombre");
String apellido = request.getParameter("txtApellido"); // Asegúrate de que exista en tu registro.jsp
String correo = request.getParameter("txtEmail");
String clave = request.getParameter("txtClave");
String estadoCivil = request.getParameter("cmbEstado");

// Validaciones mínimas
if (nombre == null || apellido == null || correo == null || clave == null || estadoCivil == null) {
%>
<div class="alert alert-danger text-center mt-5">❌ Error: Faltan
	datos obligatorios.</div>
<jsp:include page="head&foot/footer.jsp" />
</html>
<%
return;
}

// ====== 2️⃣ Crear usuario y asignar datos reales ======
Usuario nuevo = new Usuario();
nuevo.setNombre(nombre);
nuevo.setApellido(apellido);
nuevo.setCorreo(correo);
nuevo.setContrasena(clave);

// Convertir estado civil a ID
int idEst = 1;
if ("Casado".equalsIgnoreCase(estadoCivil))
idEst = 2;
else if ("Viudo".equalsIgnoreCase(estadoCivil))
idEst = 3;

nuevo.setId_estadocivil(idEst);

// Perfil fijo: VISITANTE
nuevo.setId_perfil(2);

// ====== 3️⃣ Insertar en la base de datos ======
//String resultado = nuevo.registrar();
String resultado="";
%>

<div class="container mt-5">
	<div class="card shadow p-4">

		<h2 class="text-center text-primary mb-4">Datos del Usuario
			Registrado</h2>

		<%
		if ("OK".equals(resultado)) {
		%>
		<div class="alert alert-success text-center">✅ Registro exitoso.
			Serás redirigido al inicio de sesión.</div>
		<meta http-equiv="refresh" content="3;url=login.jsp">
		<%
		} else {
		%>
		<div class="alert alert-danger text-center">
			❌ Error al registrar:
			<%=resultado%>
		</div>
		<%
		}
		%>

		<table class="table table-bordered mt-4">
			<thead class="table-light">
				<tr>
					<th colspan="2" class="text-center">Información Registrada</th>
				</tr>
			</thead>
			<tbody>
				<tr>
					<td><strong>Nombre:</strong></td>
					<td><%=nombre%> <%=apellido%></td>
				</tr>
				<tr>
					<td><strong>Estado Civil:</strong></td>
					<td><%=estadoCivil%></td>
				</tr>
				<tr>
					<td><strong>Correo Electrónico:</strong></td>
					<td><%=correo%></td>
				</tr>
				<tr>
					<td><strong>Clave:</strong></td>
					<td><%=clave%></td>
				</tr>
			</tbody>
		</table>

		<%
		if (!"OK".equals(resultado)) {
		%>
		<div class="text-center mt-3">
			<a href="registro.jsp" class="btn btn-outline-primary">Volver al
				Registro</a>
		</div>
		<%
		}
		%>

	</div>
</div>

<jsp:include page="head&foot/footer.jsp" />

