package com.ferreteria.datos;

import com.ferreteria.datos.Conexion;
import java.sql.*;
import java.util.*;

public class QueryManager {

    // Para SELECT dinámicos
    public static List<Map<String, Object>> select(String sql) {
        List<Map<String, Object>> lista = new ArrayList<>();

        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            ResultSetMetaData meta = rs.getMetaData();
            int columnas = meta.getColumnCount();

            while (rs.next()) {
                Map<String, Object> fila = new LinkedHashMap<>();
                for (int i = 1; i <= columnas; i++) {
                    fila.put(meta.getColumnLabel(i), rs.getObject(i));
                }
                lista.add(fila);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return lista;
    }

    // Para INSERT, UPDATE, DELETE
    public static int update(String sql) {
        try (Conexion cx = new Conexion();
             PreparedStatement ps = cx.getConexion().prepareStatement(sql)) {

            return ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            return -1;
        }
    }
 // ==============================================
 // MÉTODO ESPECIAL PARA CARGAR PRODUCTOS DEL POS
 // ==============================================
 public static List<Map<String, Object>> selectProductosPOS() {
     List<Map<String, Object>> lista = new ArrayList<>();

     String sql = """
         SELECT id_producto, nombre, codigo_barra, cantidad, precio_venta
         FROM tb_producto
         WHERE activo = true
         ORDER BY nombre
     """;

     try (Conexion cx = new Conexion();
          PreparedStatement ps = cx.getConexion().prepareStatement(sql);
          ResultSet rs = ps.executeQuery()) {

         while (rs.next()) {

             Map<String, Object> fila = new LinkedHashMap<>();

             fila.put("id_producto", rs.getInt("id_producto"));
             fila.put("nombre", rs.getString("nombre"));
             fila.put("codigo_barra", rs.getString("codigo_barra"));

             // Asegurar tipo entero
             fila.put("cantidad", rs.getInt("cantidad"));

             // Convertir precio_venta a double
             fila.put("precio_venta", rs.getBigDecimal("precio_venta").doubleValue());

             lista.add(fila);
         }

     } catch (Exception e) {
         e.printStackTrace();
     }

     return lista;
 }
 public static List<Map<String, Object>> ejecutarConsulta(String sql, Object... parametros) {
	    List<Map<String, Object>> lista = new ArrayList<>();

	    try (Conexion con = new Conexion();
	         PreparedStatement ps = con.getConexion().prepareStatement(sql)) {

	        // -------------------------------
	        // Asignar parámetros al query
	        // -------------------------------
	        for (int i = 0; i < parametros.length; i++) {
	            ps.setObject(i + 1, parametros[i]);
	        }

	        // -------------------------------
	        // Ejecutar SELECT
	        // -------------------------------
	        try (ResultSet rs = ps.executeQuery()) {

	            int cols = rs.getMetaData().getColumnCount();

	            // -------------------------------
	            // Convertir ResultSet → List<Map>
	            // -------------------------------
	            while (rs.next()) {
	                Map<String, Object> fila = new HashMap<>();

	                for (int c = 1; c <= cols; c++) {
	                    String col = rs.getMetaData().getColumnLabel(c);
	                    fila.put(col, rs.getObject(c));
	                }

	                lista.add(fila);
	            }

	        }

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return lista;
	}
 public static int ejecutarActualizacion(String sql, Object... parametros) {
	    int filas = 0;

	    try (Conexion con = new Conexion();
	         PreparedStatement ps = con.getConexion().prepareStatement(sql)) {

	        // Colocar parámetros en orden
	        for (int i = 0; i < parametros.length; i++) {
	            ps.setObject(i + 1, parametros[i]);
	        }

	        filas = ps.executeUpdate();

	    } catch (Exception e) {
	        e.printStackTrace();
	    }

	    return filas;
	}


}
