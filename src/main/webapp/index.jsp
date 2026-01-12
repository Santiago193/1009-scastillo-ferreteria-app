<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8" %>

<jsp:useBean id="empresa" class="com.ferreteria.empresa.Empresa" scope="application" />

<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ferretería - Página Principal</title>

    <link rel="stylesheet" href="general/general.css">

    <!-- BOOTSTRAP -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        .intro-titulo {
            font-weight: bold;
            color: #0d6efd;
            margin-bottom: 15px;
        }

        .titulo-seccion {
            font-weight: bold;
            color: #0d6efd;
            margin-bottom: 10px;
        }

        .intro {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 35px;
        }

        .contenedor-doble .bloque {
            background: white;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            margin-bottom: 30px;
            text-align: center;
        }

        /* 🔽 IMÁGENES MÁS PEQUEÑAS */
        .img-pesebre {
            margin-top: 15px;
            border-radius: 10px;
            max-width: 100%;
            height: 220px;
            object-fit: cover;
        }
    </style>
</head>

<body class="bodygeneral">

<jsp:include page="head&foot/head.jsp" />

<main class="container py-4">

    <!-- ================================= -->
    <!--      SECCIÓN DE BIENVENIDA        -->
    <!-- ================================= -->
    <section class="intro text-center">
        <h2 class="intro-titulo">Bienvenido a la Ferretería</h2>

        <p>
            Este portal presenta la información general de nuestra ferretería, incluyendo productos destacados,
            historia del negocio y una visión clara de nuestros servicios y valores.
        </p>

        <p>
            Aquí podrás conocer más sobre nuestra misión, nuestra trayectoria y los artículos que ofrecemos.
        </p>
    </section>

    <!-- ================================= -->
    <!--  SECCIÓN 1: PRODUCTOS DESTACADOS  -->
    <!-- ================================= -->
    <section class="row contenedor-doble">

        <div class="col-md-6">
            <div class="bloque">
                <h2 class="titulo-seccion">Herramientas y Equipos</h2>
                <p>
                    Contamos con una gran variedad de herramientas manuales, eléctricas y artículos especializados
                    para construcción, mantenimiento y reparaciones.
                </p>
                <img
                    src="https://images.pexels.com/photos/209235/pexels-photo-209235.jpeg"
                    class="img-pesebre"
                    alt="Herramientas de ferretería">
            </div>
        </div>

        <div class="col-md-6">
            <div class="bloque">
                <h2 class="titulo-seccion">Materiales de Construcción</h2>
                <p>
                    Desde tuberías, pinturas y adhesivos, hasta tornillería y accesorios de plomería.
                </p>
                <img
                    src="https://images.pexels.com/photos/2219024/pexels-photo-2219024.jpeg"
                    class="img-pesebre"
                    alt="Materiales de construcción">
            </div>
        </div>

    </section>

    <!-- ================================= -->
    <!--  SECCIÓN 2: HISTORIA DEL NEGOCIO  -->
    <!-- ================================= -->
    <section class="intro text-center">
        <h2 class="intro-titulo">Nuestra Historia</h2>

        <p>
            La ferretería nació como un pequeño negocio familiar comprometido con ofrecer productos
            confiables y un servicio cercano.
        </p>

        <img
            src="https://images.pexels.com/photos/416405/pexels-photo-416405.jpeg"
            class="img-pesebre"
            alt="Ferretería tradicional">
    </section>

    <!-- ================================= -->
    <!--  SECCIÓN 3: LO QUE OFRECEMOS      -->
    <!-- ================================= -->
    <section class="row contenedor-doble">

        <div class="col-md-6">
            <div class="bloque">
                <h2 class="titulo-seccion">Asesoría Profesional</h2>
                <p>
                    Nuestro personal capacitado está preparado para ayudarte a elegir correctamente.
                </p>
                <img
                    src="https://images.pexels.com/photos/209271/pexels-photo-209271.jpeg"
                    class="img-pesebre"
                    alt="Asesoría en ferretería">
            </div>
        </div>

        <div class="col-md-6">
            <div class="bloque">
                <h2 class="titulo-seccion">Calidad Garantizada</h2>
                <p>
                    Trabajamos con marcas reconocidas y productos duraderos.
                </p>
                <img
                    src="https://images.pexels.com/photos/1216589/pexels-photo-1216589.jpeg"
                    class="img-pesebre"
                    alt="Calidad en herramientas">
            </div>
        </div>

    </section>

</main>

<jsp:include page="head&foot/footer.jsp" />

</body>
</html>
