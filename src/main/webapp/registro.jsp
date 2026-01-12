<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<title>Registro de Usuario</title>

<!-- Bootstrap 5 -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

<!-- Iconos Bootstrap -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    .error-msg {
        color: red;
        font-size: 13px;
        margin-top: 4px;
    }

    .registro-wrapper {
        display: flex;
        justify-content: center;
        margin-top: 40px;
        margin-bottom: 40px;
    }

    .registro-card {
        width: 100%;
        max-width: 500px;
        padding: 30px;
        border-radius: 12px;
        background: white;
        box-shadow: 0 4px 14px rgba(0,0,0,0.15);
    }

    .titulo-registro {
        text-align: center;
        font-weight: bold;
        color: #0d6efd;
        margin-bottom: 20px;
    }
</style>

<script>
function validarFormulario() {

    let nombre = document.getElementById("nombre");
    let apellido = document.getElementById("apellido");
    let estado = document.getElementById("estado");
    let email = document.getElementById("email");
    let clave = document.getElementById("clave");

    let valido = true;

    document.querySelectorAll(".error-msg").forEach(e => e.remove());

    function mostrarError(campo, mensaje) {
        let div = document.createElement("div");
        div.className = "error-msg";
        div.textContent = mensaje;
        campo.parentNode.appendChild(div);
        valido = false;
    }

    if (nombre.value.trim() === "")
        mostrarError(nombre, "Ingrese su nombre.");
    else if (!/^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$/.test(nombre.value))
        mostrarError(nombre, "El nombre solo debe contener letras.");

    if (apellido.value.trim() === "")
        mostrarError(apellido, "Ingrese su apellido.");
    else if (!/^[A-Za-zÁÉÍÓÚáéíóúñÑ ]+$/.test(apellido.value))
        mostrarError(apellido, "El apellido solo debe contener letras.");

    if (estado.value === "")
        mostrarError(estado, "Seleccione un estado civil.");

    let expEmail = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (email.value.trim() === "")
        mostrarError(email, "Ingrese su correo electrónico.");
    else if (!expEmail.test(email.value))
        mostrarError(email, "Ingrese un correo válido.");

    if (clave.value.trim() === "")
        mostrarError(clave, "Ingrese una contraseña.");
    else if (clave.value.length < 6)
        mostrarError(clave, "La contraseña debe tener al menos 6 caracteres.");

    return valido;
}
</script>

</head>

<body class="bodygeneral">
<jsp:include page="head&foot/head.jsp" />

<div class="registro-wrapper">
    <div class="registro-card">

        <h2 class="titulo-registro">Registro de nuevo usuario</h2>

        <form action="nuevoCliente.jsp" method="post" onsubmit="return validarFormulario()">

            <!-- Nombre -->
            <div class="mb-3">
                <label class="form-label">Nombre</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person"></i></span>
                    <input type="text" id="nombre" name="txtNombre" class="form-control" required>
                </div>
            </div>

            <!-- Apellido -->
            <div class="mb-3">
                <label class="form-label">Apellido</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person-bounding-box"></i></span>
                    <input type="text" id="apellido" name="txtApellido" class="form-control" required>
                </div>
            </div>

            <!-- Estado civil -->
            <div class="mb-3">
                <label class="form-label">Estado civil</label>
                <select id="estado" name="cmbEstado" class="form-select" required>
                    <option value="">-- Seleccione --</option>
                    <option>Soltero</option>
                    <option>Casado</option>
                    <option>Viudo</option>
                </select>
            </div>

            <!-- Correo -->
            <div class="mb-3">
                <label class="form-label">Correo electrónico</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-envelope"></i></span>
                    <input type="email" id="email" name="txtEmail" class="form-control"
                           placeholder="usuario@correo.com" required>
                </div>
            </div>

            <!-- Clave -->
            <div class="mb-3">
                <label class="form-label">Contraseña</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                    <input type="password" id="clave" name="txtClave" class="form-control" required>
                </div>
            </div>

            <!-- BOTONES -->
            <div class="d-grid gap-2 mt-3">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-circle me-1"></i> Enviar
                </button>

                <button type="reset" class="btn btn-secondary">
                    <i class="bi bi-eraser me-1"></i> Limpiar
                </button>
            </div>

        </form>

    </div>
</div>

<jsp:include page="head&foot/footer.jsp" />

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
