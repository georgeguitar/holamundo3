/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package almacenes;

import almacenes.interfaces.Login;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import almacenes.conectorDB.DatosConexion;
import java.sql.DriverManager;

/**
 *
 * @author georgeguitar
 */
public class Principal {
//    private static DatabaseUtils databaseUtils;
    private static Connection connectionDB;
    
    
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            Class.forName(almacenes.conectorDB.DatosConexion.DEFAULT_DRIVER);
            connectionDB = DriverManager.getConnection(almacenes.conectorDB.DatosConexion.DEFAULT_URL +
                    almacenes.conectorDB.DatosConexion.DB_HOST + "/"+ almacenes.conectorDB.DatosConexion.DB_NAME, 
                    almacenes.conectorDB.DatosConexion.DEFAULT_USERNAME, 
                    almacenes.conectorDB.DatosConexion.DEFAULT_PASSWORD);
            System.out.println(connectionDB);
            new Login(connectionDB).setVisible(true);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(Principal.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(Principal.class.getName()).log(Level.SEVERE, null, ex);
        }
        new Login(connectionDB).setVisible(true);
    }

}
