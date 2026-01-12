package com.ferreteria.admin;

import com.ferreteria.datos.Conexion;
import java.sql.*;
import java.util.*;

public class Proveedor {

    private int id;
    private String nombre;

    public int getId(){ return id; }
    public String getNombre(){ return nombre; }

    public static void insertar(String nombre, String telefono, String correo, String ubicacion) {
        String sql = "INSERT INTO tb_proveedor(nombre, telefono, correo, ubicacion) VALUES (?, ?, ?, ?)";

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql)) {

            ps.setString(1, nombre);
            ps.setString(2, telefono);
            ps.setString(3, correo);
            ps.setString(4, ubicacion);
            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static List<Proveedor> listar() {
        List<Proveedor> lista = new ArrayList<>();
        String sql = "SELECT id_proveedor, nombre FROM tb_proveedor ORDER BY nombre";

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Proveedor p = new Proveedor();
                p.id = rs.getInt("id_proveedor");
                p.nombre = rs.getString("nombre");
                lista.add(p);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }
}
