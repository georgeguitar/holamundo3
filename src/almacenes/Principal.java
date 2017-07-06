/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package almacenes;

import almacenes.conectorDB.DatabaseUtils;
import almacenes.interfaces.Login;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import almacenes.conectorDB.DatosConexion;

/**
 *
 * @author georgeguitar
 */
public class Principal {
    private static DatabaseUtils databaseUtils;
    private static Connection connectionDB;
    
    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try { 
            databaseUtils = new DatabaseUtils();
            connectionDB = databaseUtils.createConnection(almacenes.conectorDB.DatosConexion.DEFAULT_DRIVER,
                    almacenes.conectorDB.DatosConexion.DEFAULT_URL +
                    almacenes.conectorDB.DatosConexion.DB_HOST + ":" +
                    almacenes.conectorDB.DatosConexion.DB_PORT + "/" +
                    almacenes.conectorDB.DatosConexion.DB_NAME, 
                    almacenes.conectorDB.DatosConexion.DEFAULT_USERNAME, 
                    almacenes.conectorDB.DatosConexion.DEFAULT_PASSWORD);
            connectionDB.setAutoCommit(true);
            new Login(databaseUtils,connectionDB).setVisible(true);
        } catch (ClassNotFoundException | SQLException ex) {
//                databaseUtils.rollback(connectionDB);
            //Logger.getLogger(BuscarPersona.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            //databaseUtils.close(connectionDB);
        }
    }
    
}
