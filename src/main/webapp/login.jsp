<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ingreso al Sistema</title>

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- ICONOS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        .login-wrapper {
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 70vh;
            padding: 40px 15px;
        }

        .login-card {
            width: 100%;
            max-width: 420px;
            background: #ffffff;
            border-radius: 12px;
            padding: 35px 30px;
            box-shadow: 0 4px 18px rgba(0,0,0,0.12);
        }

        .login-title {
            text-align: center;
            font-weight: 700;
            margin-bottom: 10px;
            color: #0d6efd;
        }

        .login-subtitle {
            text-align: center;
            font-size: 15px;
            color: #555;
            margin-bottom: 25px;
        }

        .register-text {
            text-align: center;
            margin-top: 20px;
            font-size: 15px;
        }

        .register-text a {
            font-weight: 600;
            color: #0d6efd;
            text-decoration: none;
        }

        .register-text a:hover {
            text-decoration: underline;
        }

        .login-error {
            color: #dc3545;
            font-weight: 600;
            text-align: center;
            margin-bottom: 15px;
        }
    </style>
</head>

<body class="bodygeneral">
<jsp:include page="head&foot/head.jsp" />

<div class="login-wrapper">

    <div class="login-card">

        <h2 class="login-title">Ingreso al Sistema</h2>
        <p class="login-subtitle">Introduce tus credenciales para continuar</p>

        <% if (request.getParameter("error") != null) { %>
            <p class="login-error"><%= request.getParameter("error") %></p>
        <% } %>

        <form action="validarLogin.jsp" method="post">

            <!-- Usuario -->
            <div class="mb-3">
                <label class="form-label">Usuario (correo)</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-person-circle"></i></span>
                    <input type="text" class="form-control" name="usuario" required>
                </div>
            </div>

            <!-- Clave -->
            <div class="mb-3">
                <label class="form-label">Clave</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" class="form-control" name="clave" required>
                </div>
            </div>

            <!-- Botones -->
            <div class="d-grid gap-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-box-arrow-in-right me-1"></i> Ingresar
                </button>

                <button type="reset" class="btn btn-secondary">
                    <i class="bi bi-eraser-fill me-1"></i> Limpiar
                </button>
            </div>

        </form>

        <div class="register-text">
            ¿No tienes cuenta?
            <a href="registro.jsp">Regístrate aquí</a>
        </div>

    </div>

</div>

<jsp:include page="head&foot/footer.jsp" />

<!-- BOOTSTRAP JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>
