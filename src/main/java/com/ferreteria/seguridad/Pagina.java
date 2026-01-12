package com.ferreteria.seguridad;

import java.sql.PreparedStatement;
import java.sql.ResultSet;

import com.ferreteria.datos.Conexion;
import com.ferreteria.empresa.Empresa;

public class Pagina {

    public String mostrarMenu(Integer perfil) {

        StringBuilder menu = new StringBuilder();

        // ======================================================
        // DATOS DE EMPRESA
        // ======================================================
        Empresa emp = new Empresa(); // carga automática desde BD
        String nombreEmp = emp.getNombre() != null ? emp.getNombre() : "Mi Empresa";
        String sloganEmp = emp.getSlogan() != null ? emp.getSlogan() : "";

        // ======================================================
        // ENCABEZADO (Bootstrap)
        // ======================================================
        menu.append("""
            <div class='text-center mb-3'>
                <h3 class='fw-bold'>""" + nombreEmp + "</h3>" + """
                <p class='text-muted'>""" + sloganEmp + "</p>" + """
            </div>
        """);

        // ======================================================
        // SQL CONSULTA
        // ======================================================
        String sql = """
            SELECT pag.id_pagina, pag.nombre, pag.url
            FROM tb_pagina pag
            JOIN tb_perfilpagina pper ON pag.id_pagina = pper.id_pagina
            WHERE pper.id_perfil = ?
            ORDER BY pag.id_pagina
        """;

        try (Conexion con = new Conexion();
             PreparedStatement ps = con.getConexion().prepareStatement(sql)) {

            ps.setInt(1, perfil);
            ResultSet rs = ps.executeQuery();

            // ======================================================
            // BOTONES DEL MENÚ (Bootstrap)
            // ======================================================
            menu.append("<div class='d-flex flex-wrap justify-content-center gap-2'>");

            while (rs.next()) {
                int idPag = rs.getInt("id_pagina");
                String nombrePag = rs.getString("nombre");
                String urlPag = rs.getString("url");

                menu.append("""
                    <a href='""" + urlPag + "?accesskey=" + idPag + "' " + """
                       class='btn btn-outline-primary btn-sm px-3'>
                        """ + nombrePag + """
                    </a>
                """);
            }

            menu.append("</div>");

        } catch (Exception e) {
            System.out.println("❌ Error en mostrarMenu(): " + e.getMessage());
        }

        return menu.toString();
    }

}
