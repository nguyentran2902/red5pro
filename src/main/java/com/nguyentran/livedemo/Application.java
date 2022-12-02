package com.nguyentran.livedemo;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import org.red5.server.adapter.MultiThreadedApplicationAdapter;
import org.red5.server.api.IClient;
import org.red5.server.api.IConnection;
import org.red5.server.api.Red5;
import org.red5.server.api.scope.IScope;
import org.red5.server.api.stream.IBroadcastStream;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;

public class Application extends MultiThreadedApplicationAdapter implements ApplicationContextAware{

	@Override
	public boolean appConnect(IConnection conn, Object[] params) {
		// TODO Auto-generated method stub
		return super.appConnect(conn, params);
	}

	@Override
	public void appDisconnect(IConnection conn) {
		// TODO Auto-generated method stub
		super.appDisconnect(conn);
	}

	@Override
	public boolean appStart(IScope app) {
		// TODO Auto-generated method stub
		return super.appStart(app);
	}
	
    public void streamBroadcastStart(IBroadcastStream stream) {

        IConnection connection = Red5.getConnectionLocal();
        if (connection != null &&  stream != null) {
          System.out.println("Broadcast started for: " + stream.getPublishedName());
          connection.setAttribute("streamStart", System.currentTimeMillis());
          connection.setAttribute("streamName", stream.getPublishedName());
        }

    }
    
    public List<String> getLiveStreams() {

        Iterator<IClient> iter = scope.getClients().iterator();
        List<String> streams = new ArrayList<String>();

        THE_OUTER:while(iter.hasNext()) {

          IClient client = iter.next();
          Iterator<IConnection> cset = client.getConnections().iterator();

          THE_INNER:while(cset.hasNext()) {
            IConnection c = cset.next();
            if (c.hasAttribute("streamName")) {
              if (!c.isConnected()) {
                try {
                  c.close();
                  client.disconnect();
                }
                catch(Exception e) {
                  // Failure to close/disconnect.
                }
                continue THE_OUTER;
              }

              if (streams.contains(c.getAttribute("streamName").toString())) {
                continue THE_INNER;
              }

              streams.add(c.getAttribute("streamName").toString());
            }
          }
        }

        return streams;
    }
    
   

	@Override
	public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
		// TODO Auto-generated method stub
		
	}


}
