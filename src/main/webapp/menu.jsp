<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" session="true" import="com.ferreteria.seguridad.*"%>

<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Ferretería - Sistema de Información</title>
<link rel="stylesheet" href="general/general.css">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">


<style>
    .hero-navidad {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: 20px;
        padding: 40px 20px;
        background: #f8f9fa;
        border-radius: 12px;
        margin-bottom: 40px;
    }

    .hero-texto h1 {
        font-size: 2.3rem;
        font-weight: 700;
        color: #0d6efd;
    }

    .hero-texto p {
        font-size: 1.1rem;
        color: #555;
        max-width: 500px;
    }

    .hero-img {
        width: 350px;
        max-width: 100%;
    }

    .seccion-info {
        text-align: center;
        padding: 40px 20px;
        margin-bottom: 35px;
        background: #ffffff;
        border-radius: 12px;
        box-shadow: 0 2px 6px rgba(0,0,0,.08);
    }

    .seccion-info h2 {
        color: #0d6efd;
        margin-bottom: 15px;
        font-weight: 700;
    }

    .seccion-info p {
        max-width: 800px;
        margin: 0 auto 20px auto;
        font-size: 1.05rem;
        color: #444;
    }

    .info-img {
        width: 420px;
        max-width: 100%;
        margin-top: 15px;
    }

    .footer-navidad {
        text-align: center;
        padding: 20px;
        margin-top: 40px;
        background: #f1f3f5;
        border-radius: 10px;
        font-weight: 500;
        color: #333;
    }
</style>
</head>

<body class="bodygeneral">

<!-- Menú superior -->
<jsp:include page="head&foot/menuu.jsp" />

<div class="container py-4">

    <!-- ===================================== -->
    <!-- HERO -->
    <!-- ===================================== -->
    <section class="hero-navidad">
        <div class="hero-texto">
            <h1>🛠️ Bienvenido a Nuestra Ferretería 🛠️</h1>
            <p>Conoce más sobre nuestro negocio, nuestra historia y los productos que ofrecemos.</p>
        </div>

        <img src="https://markemstore.com/cdn/shop/collections/herramientas-manuales-253628.png?v=1748500821"
             class="hero-img img-fluid"
             alt="Ferretería Hero">
    </section>


    <!-- ===================================== -->
    <!-- SECCIÓN 1 -->
    <!-- ===================================== -->
    <section class="seccion-info">
        <h2>🔧 Quiénes Somos</h2>
        <p>
            Somos una ferretería comprometida con brindar productos de calidad, asesoría profesional y un servicio cercano.
            Trabajamos para ofrecer soluciones tanto para profesionales de la construcción como para hogares.
        </p>

        <img src="https://markemstore.com/cdn/shop/collections/herramientas-manuales-253628.png?v=1748500821"
             class="info-img img-fluid"
             alt="Información General">
    </section>


    <!-- ===================================== -->
    <!-- SECCIÓN 2 -->
    <!-- ===================================== -->
    <section class="seccion-info">
        <h2>🛒 Variedad de Productos</h2>
        <p>
            Contamos con herramientas, materiales de construcción, artículos eléctricos, plomería, pinturas,
            adhesivos, tornillería y muchos productos más. Nos enfocamos en ofrecer marcas confiables y duraderas.
        </p>

        <img src="https://markemstore.com/cdn/shop/collections/herramientas-manuales-253628.png?v=1748500821"
             class="info-img img-fluid"
             alt="Productos Ferretería">
    </section>


    <!-- ===================================== -->
    <!-- SECCIÓN 3 -->
    <!-- ===================================== -->
    <section class="seccion-info">
        <h2>📜 Nuestra Historia</h2>
        <p>
            Empezamos como un pequeño negocio familiar enfocado en apoyar a la comunidad local.
            Con el tiempo hemos crecido, pero mantenemos los mismos valores de honestidad,
            confianza y compromiso con cada uno de nuestros clientes.
        </p>

        <img src="https://markemstore.com/cdn/shop/collections/herramientas-manuales-253628.png?v=1748500821"
             class="info-img img-fluid"
             alt="Historia Ferretería">
    </section>


    <!-- ===================================== -->
    <!-- SECCIÓN 4 -->
    <!-- ===================================== -->
    <section class="seccion-info">
        <h2>⭐ Nuestro Compromiso</h2>
        <p>
            Nos esforzamos por ofrecer productos de calidad, atención personalizada y asesoría adecuada para
            que cada cliente encuentre exactamente lo que necesita, ya sea para un proyecto grande o una reparación en casa.
        </p>

        <img src="https://markemstore.com/cdn/shop/collections/herramientas-manuales-253628.png?v=1748500821"
             class="info-img img-fluid"
             alt="Calidad y Servicio">
    </section>


    <!-- ===================================== -->
    <!-- FOOTER -->
    <!-- ===================================== -->
    <footer class="footer-navidad">
        <p>🛠️ Ferretería - Información General • 2025 🛠️</p>
    </footer>

</div>

</body>
</html>
