package com.ferreteria.datos;

import java.sql.*;

public class Conexion implements AutoCloseable {

    private final String driver = "org.postgresql.Driver";
    private final String user   = "postgres";
    //private final String pwd    = "jesscamas1234";
    //private final String cadena = "jdbc:postgresql://localhost:5432/ferreteria";
    private final String pwd    = "1234";
    private final String cadena = "jdbc:postgresql://localhost:5432/ferre";

    private Connection con;

    // ===========================================================
    //  CONSTRUCTOR
    // ===========================================================
    public Conexion() {
        this.con = crearConexion();
    }

    // ===========================================================
    //  CREAR CONEXIÓN
    // ===========================================================
    private Connection crearConexion() {
        try {
            Class.forName(driver);
            return DriverManager.getConnection(cadena, user, pwd);

        } catch (Exception e) {
            System.out.println("❌ Error al conectar: " + e.getMessage());
            return null;
        }
    }

    public Connection getConexion() {
        return this.con;
    }

    // ===========================================================
    //  CERRAR CONEXIÓN (para usar try-with-resources)
    // ===========================================================
    @Override
    public void close() {
        try {
            if (con != null && !con.isClosed()) {
                con.close();
            }
        } catch (Exception e) {
            System.out.println("❌ Error al cerrar conexión: " + e.getMessage());
        }
    }

    // ===========================================================
    //  EJECUTAR SQL DIRECTO (INSERT/UPDATE/DELETE)
    //  ⚠ SOLO PARA USOS CONTROLADOS
    // ===========================================================
    public String Ejecutar(String sql) {
        try (Statement st = con.createStatement()) {

            int filas = st.executeUpdate(sql);
            return filas > 0 ? "OK" : "Sin cambios";

        } catch (Exception ex) {
            System.out.println("❌ ERROR SQL: " + sql);
            System.out.println("Detalle: " + ex.getMessage());
            return ex.getMessage();
        }
    }

    // ===========================================================
    //  CONSULTA DIRECTA (SELECT)
    // ===========================================================
    public ResultSet Consulta(String sql) {
        try {
            Statement st = con.createStatement();
            return st.executeQuery(sql);

        } catch (Exception e) {
            System.out.println("❌ Error en consulta directa: " + e.getMessage());
            return null;
        }
    }

    // ===========================================================
    //  MÉTODOS SEGUROS (ANTI-INYECCIÓN SQL)
    // ===========================================================

    // INSERT / UPDATE / DELETE seguros
    public int EjecutarSeguro(String sql, Object... parametros) {
        try (PreparedStatement ps = con.prepareStatement(sql)) {

            for (int i = 0; i < parametros.length; i++) {
                ps.setObject(i + 1, parametros[i]);
            }

            return ps.executeUpdate();

        } catch (Exception e) {
            System.out.println("❌ Error SQL seguro: " + e.getMessage());
            return -1;
        }
    }

    // SELECT seguro
    public ResultSet ConsultaSeguro(String sql, Object... parametros) {
        try {
            PreparedStatement ps = con.prepareStatement(sql);

            for (int i = 0; i < parametros.length; i++) {
                ps.setObject(i + 1, parametros[i]);
            }

            return ps.executeQuery();

        } catch (Exception e) {
            System.out.println("❌ Error en consulta segura: " + e.getMessage());
            return null;
        }
    }
}
