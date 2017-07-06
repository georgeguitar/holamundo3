

import java.sql.Connection;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Calendar;

import almacenes.conectorDB.DatabaseUtils;
import almacenes.negocio.Reglas;
import almacenes.negocio.mapeo.Credito;
import almacenes.negocio.mapeo.Persona;
import almacenes.negocio.mapeo.PersonaTieneCredito;
import almacenes.negocio.mapeo.Usuario;
import java.util.ArrayList;

public class BusquedasTest {

    public static Connection connection;
    public static Statement stmt; 
    public static ResultSet rs;

    static DatabaseUtils databaseUtils;
	
    private static final String DEFAULT_DRIVER = "org.postgresql.Driver";
    private static final String DEFAULT_URL = "jdbc:postgresql://localhost:5432/creditosDB";
    private static final String DEFAULT_USERNAME = "postgres";
    private static final String DEFAULT_PASSWORD = "postgres";
	
    static final String CLIENTE = "CLIENTE";
    static final String GARANTE = "GARANTE";
    static final String BOLIVIANOS = "BOB";
    static final String DOLARES = "$US";
    static final String CUOTA_FIJA = "CUOTA_FIJA";
    static final String INTERES_FIJO = "INTERES_FIJO";
    static final String NINGUNO = "NINGUNO";

    static String Decimales = "%.2f";  // Dos decimales	

    public static void main(String[] args) {

    try {
        databaseUtils = new DatabaseUtils();
        connection = databaseUtils.createConnection(DEFAULT_DRIVER, DEFAULT_URL, DEFAULT_USERNAME, DEFAULT_PASSWORD);
        Reglas reglas = new Reglas(databaseUtils, connection);

        // TODO add your handling code here:
        Persona personaBuscar = new Persona();
        personaBuscar.setIdPersona(19L);    
        personaBuscar.setCI(8484844);    
        personaBuscar.setNombres("Pedro");    
        personaBuscar.setApPaterno("Madrigas");
        personaBuscar.setApMaterno("Corredon");
        ArrayList<Persona> listaPersonasEncontradas = new ArrayList<Persona>();
//        listaPersonasEncontradas = reglas.buscarPersona(personaBuscar);

        for (Persona personaEncontrada : listaPersonasEncontradas) {
            System.out.println("getIdPersona: " + personaEncontrada.getIdPersona());
            System.out.println("getCI: " + personaEncontrada.getCI());
            System.out.println("getNombres: " +  personaEncontrada.getNombres());
            System.out.println("getApPaterno: " +  personaEncontrada.getApPaterno());
            System.out.println("getApMaterno: " +  personaEncontrada.getApMaterno());
            System.out.println("getSexo: " +  personaEncontrada.getSexo());
            System.out.println("getFechaNacimiento: " +  personaEncontrada.getFechaNacimiento());
            System.out.println("getTelefono: " +  personaEncontrada.getTelefono());
            System.out.println("getTelCelular: " +  personaEncontrada.getTelCelular());
            System.out.println("getEmail: " +  personaEncontrada.getEmail());
//            System.out.println("getDireccion: " + personaEncontrada.getDireccion());
            System.out.println("getOcupacion: " +  personaEncontrada.getOcupacion());
            System.out.println("getDatosAdicionales: " + personaEncontrada.getDatosAdicionales());
        }

        } catch (Exception e) {
//	    	conectionDB.rollback(connection);
            e.printStackTrace();
        } finally {
            databaseUtils.close(connection);
        }

    }
        
}
