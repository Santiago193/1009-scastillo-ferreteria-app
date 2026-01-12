<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.ferreteria.empresa.Empresa"%>

<jsp:useBean id="datosEmpresa" class="com.ferreteria.empresa.Empresa"
	scope="session" />

<meta charset="UTF-8">

<!-- BOOTSTRAP -->
<link
	href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css"
	rel="stylesheet">
<link rel="stylesheet" href="general/general.css">
<link rel="stylesheet" href="../general/general.css">

<body class="navidad-bg">
	<main class="container py-4">

		<!-- ========================================= -->
		<!--            ENCABEZADO PRINCIPAL            -->
		<!-- ========================================= -->
		<header class="text-center mb-4">

			<h1 class="fw-bold text-primary">
				<%=datosEmpresa.getNombre() != null ? datosEmpresa.getNombre() : "Nombre Empresa"%>
			</h1>

			<h3 class="text-secondary">
				<%=datosEmpresa.getSlogan() != null ? datosEmpresa.getSlogan() : ""%>
			</h3>

			<p class="fs-5 mt-2" id="favorito">
				<%=datosEmpresa.getDescripcion() != null ? datosEmpresa.getDescripcion() : ""%>
			</p>

		</header>


		<!-- ========================================= -->
		<!--                NAVBAR BOOTSTRAP           -->
		<!-- ========================================= -->
		<nav
			class="navbar navbar-expand-lg navbar-dark bg-primary rounded shadow-sm mb-4">

			<div class="container-fluid">

				<a class="navbar-brand fw-bold" href="index.jsp"> Inicio </a>

				<button class="navbar-toggler" type="button"
					data-bs-toggle="collapse" data-bs-target="#navbarNav"
					aria-controls="navbarNav" aria-expanded="false"
					aria-label="Toggle navigation">
					<span class="navbar-toggler-icon"></span>
				</button>

				<div class="collapse navbar-collapse" id="navbarNav">

					<ul class="navbar-nav ms-auto">

						<li class="nav-item"><a
							class="nav-link text-white fw-semibold" href="index.jsp">Principal</a>
						</li>

						<li class="nav-item"><a
							class="nav-link text-white fw-semibold" href="login.jsp">Login</a>
						</li>

					</ul>

				</div>

			</div>

		</nav>