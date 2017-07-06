package almacenes.conectorDB;

import java.sql.*;
import java.util.*;

public class DatabaseUtils {
	
	public DatabaseUtils(){}
	
//	Connection connection = null;

    public Connection createConnection(String driver, String url, String username, String password) throws ClassNotFoundException, SQLException
    {
        Class.forName(driver);

        if ((username == null) || (password == null) || (username.trim().length() == 0) || (password.trim().length() == 0))
        {
            return DriverManager.getConnection(url);
        }
        else
        {
            return DriverManager.getConnection(url, username, password);
        }
    }

    public void close(Connection connection)
    {
        try
        {
            if (connection != null)
            {
                connection.close();
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }


    public void close(Statement st)
    {
        try
        {
            if (st != null)
            {
                st.close();
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    public void close(ResultSet rs)
    {
        try
        {
            if (rs != null)
            {
                rs.close();
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    public void rollback(Connection connection)
    {
        try
        {
            if (connection != null)
            {
                connection.rollback();
            }
        }
        catch (SQLException e)
        {
            e.printStackTrace();
        }
    }

    public List<Map<String, Object>> map(ResultSet rs) throws SQLException
    {
        List<Map<String, Object>> results = new ArrayList<Map<String, Object>>();

        try
        {
            if (rs != null)
            {
                ResultSetMetaData meta = rs.getMetaData();
                int numColumns = meta.getColumnCount();
                while (rs.next())
                {
                    Map<String, Object> row = new HashMap<String, Object>();
                    for (int i = 1; i <= numColumns; ++i)
                    {
                        String name = meta.getColumnName(i);
                        Object value = rs.getObject(i);
                        row.put(name, value);
                    }
                    results.add(row);
                }
            }
        }
        finally
        {
            close(rs);
        }

        return results;
    }

    public List<Map<String, Object>> query(Connection connection, String sql, List<Object> parameters) throws SQLException
    {
        List<Map<String, Object>> results = null;

        PreparedStatement ps = null;
        ResultSet rs = null;

        try
        {
            ps = connection.prepareStatement(sql);

            int i = 0;
            for (Object parameter : parameters)
            {
                ps.setObject(++i, parameter);
            }

            rs = ps.executeQuery();
            results = map(rs);
        }
        finally
        {
            close(rs);
            close(ps);
        }

        return results;
    }

    public int update(Connection connection, String sql, List<Object> parameters) throws SQLException
    {
        int numRowsUpdated = 0;

        PreparedStatement ps = null;

        try
        {
            ps = connection.prepareStatement(sql);

            int i = 0;
            for (Object parameter : parameters)
            {
                ps.setObject(++i, parameter);
            }

            numRowsUpdated = ps.executeUpdate();
        }
        finally
        {
            close(ps);
        }

        return numRowsUpdated;
    }
    
    
	public Long ejecutarFuncionArrayPL(Connection connection, String funcion,  ArrayList<String> parametros) throws SQLException {
		Long resultado = 0L;
		
		CallableStatement callable = connection.prepareCall("{ ? = call " + funcion + " ( ? ) }");

		callable.registerOutParameter(1, Types.BIGINT);
		Array stringsArray = connection.createArrayOf("varchar", parametros.toArray(new String[parametros.size()]));
		callable.setArray(2, stringsArray);
		callable.execute();
		resultado = callable.getLong(1);
		callable.close();
		
		return resultado;
	}
}
