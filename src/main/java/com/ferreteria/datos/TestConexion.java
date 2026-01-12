package com.ferreteria.datos;

public class TestConexion {
    public static void main(String[] args) {
        Conexion con = new Conexion();
        if (con.getConexion() != null) {
            System.out.println("✅ Conexión establecida correctamente");
        } else {
            System.out.println("❌ Error al conectar con la base de datos");
        }
    }
}
