package com.unstoppable.wmp.timer;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
import android.widget.TextView;

public class Timer extends Activity {

	long leftOver;
	long timeInput = 70000;
	long measureBy = 1000;
	boolean paused = false;
	
	String thrity = "35000";
	String forty = "40000";
	String fifty = "50000";
	String onehalf = "90000";
	
	private ArrayList<String> values;
	
	
	final String FILENAME = "timer1.txt";
	
	class CDTimer extends CountDownTimer {
		
		public CDTimer(long millisInFuture, long countDownInterval) {
			super(millisInFuture, countDownInterval);
			// TODO Auto-generated constructor stub
		}
		
		private CDTimer(long time){
			this(time,measureBy);
		}

		private long timeLeft;

	     public void onTick(long millisUntilFinished) {
	    	 ((TextView)findViewById(R.id.timer)).setText(formatTimeText(millisUntilFinished));
	    	 timeLeft = millisUntilFinished;
	    	 Log.d("timeLeft", String.valueOf(timeLeft));
	     }

	     public void onFinish() {
	    	 this.cancel();
	         hideStopButton();
	         ((TextView)findViewById(R.id.timer)).setText("00:00:00");
	     }
	     
	     public void onPause() {
	    	 leftOver = timeLeft;
	    	 this.cancel();
	    	 Log.d("cancel", "caneled called");
	    	 paused = true;
	     }
	     
	  };
	
	CDTimer counter;
	
	@Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_timer);
        
        
      //call read create and load info into field below
        values = new ArrayList<String>();
        ListView listview = (ListView) findViewById(R.id.saved_list);
		ArrayAdapter<String> adapter = new ArrayAdapter<String>(this, android.R.layout.simple_selectable_list_item, values);
		listview.setAdapter(adapter);
		listview.setItemsCanFocus(false);
		listview.setChoiceMode(ListView.CHOICE_MODE_MULTIPLE);
		registerForContextMenu(listview);
    }
	

	public void onListItemClick(ListView l, View v, int position, long id) {
		
		 
	}

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_timer, menu);
        return true;
    }
 
    @Override
	public void onPause(){
		super.onPause();
		values.clear();
		Log.d("leftOver", String.valueOf(values.size()));
		for(int i = 0; i < values.size(); i++){
			writeToFile(values.get(i));
		}		
	}
    
    @Override
    public void onResume(){
    	super.onResume();
    	readFromFile();
    }
    
    public void onDestory(){
    	super.onDestroy();
    	values.clear();
    }

    public void startClick(View view) {
    	
    	showStopButton();
    	if(paused){
    		Log.d("LeftOver", String.valueOf(leftOver));
    		counter = new CDTimer(leftOver);
    		paused = false;
    	}
    	else
    		counter = new CDTimer(timeInput);
    	counter.start();
    }
	public void stopClick(View view) {
    	
    	hideStopButton();
		counter.onPause();
    	
    }
	
	public void resetClick(View view) {
    	
    	showStopButton();
		counter.onFinish();
		paused = false;
    	
    }
    
    public void saveClick(View view) {
    	//writeToFile(String.valueOf(timeInput));
    	values.add(String.valueOf(timeInput));
    	ListView listview = (ListView) findViewById(R.id.saved_list);
		ArrayAdapter<String> adapter = (ArrayAdapter<String>) listview.getAdapter();
		adapter.notifyDataSetChanged();
    	//reload bottom part of screen to show updates
    }
    
	private boolean writeToFile(String input) {
		
		try
    	{
    		FileOutputStream fos = openFileOutput(FILENAME, Context.MODE_PRIVATE);
    		input = input + '\n';
    		fos.write(input.getBytes());
    		fos.close();    		
    		Log.d("README", "wrote " + input + " To the file " + FILENAME);
    		return true;
    	}
    	catch(IOException e)
    	{
    		Log.e("README", "write " + input + " To the file " + FILENAME + "failed");
    		return false;
    	}
	}
    
	private boolean readFromFile() {
		
		String output ;
		try 
        {
        	//Sets up the InputStream to read from a file
        	FileInputStream in = openFileInput(FILENAME);
            InputStreamReader inputStreamReader = new InputStreamReader(in);
            BufferedReader bufferedReader = new BufferedReader(inputStreamReader);
            
            //Loop breaks when all the data is read
            while ((output = bufferedReader.readLine()) != null) 
            {
                values.add(output);
                Log.d("README", "Read Line: " + output);
                
            }
            return true;
        } 
        catch (IOException e) {
			// TODO Auto-generated catch block
        	Log.e("README", "read From " + FILENAME + " failed");
        	return false;
			//e.printStackTrace();
		}
	}
    
	private String formatWordText(long time) {
		
		String savedTimer = "";
		Log.d("LOOKATME",String.valueOf(time));
    	long sec = (time/1000) % 60;
		long min = ((time/1000)/60) % 60;
		long hr = (((time/1000)/60)/60) % 60;
		
		if (hr > 0){
			savedTimer += String.valueOf(hr) + " hours";
		}
		if (min > 0){
			savedTimer += String.valueOf(min) + " mins";
		}
		if (sec > 0){
			savedTimer += String.valueOf(sec) + " sec";
		}
		
		Log.d("LOOKATME",String.valueOf(sec));
//		String secS = addZero(sec);
	//	String minS = addZero(min);
		//String hrS = addZero(hr);
		
		return savedTimer;
	}
	
	//change this
   
	private void showStopButton(){
        ((Button)findViewById(R.id.startButton)).setVisibility(View.GONE);
        ((Button)findViewById(R.id.resetButton)).setVisibility(View.GONE);
        ((Button)findViewById(R.id.stopButton)).setVisibility(View.VISIBLE);
    }

    //change this
    //Used to hide the stop button and show the reset and start button
    private void hideStopButton(){
        ((Button)findViewById(R.id.startButton)).setVisibility(View.VISIBLE);
        ((Button)findViewById(R.id.resetButton)).setVisibility(View.VISIBLE);
        ((Button)findViewById(R.id.stopButton)).setVisibility(View.GONE);
    }
    
    private String formatTimeText(long number){
    	
    	Log.d("LOOKATME",String.valueOf(number));
    	long sec = (number/1000) % 60;
		long min = ((number/1000)/60) % 60;
		long hr = (((number/1000)/60)/60) % 60;
		
		Log.d("LOOKATME",String.valueOf(sec));
		String secS = addZero(sec);
		String minS = addZero(min);
		String hrS = addZero(hr);
		
		return hrS + ':' + minS + ':' + secS;
    	
    }
   
    private String addZero(long value){
    	String answer;
    	if (value < 10 && value > 0){
    		answer = '0' + String.valueOf(value);
    	}
    	else if (value == 0){
    		answer = "00";
    	}
    	else{
    		answer = String.valueOf(value);
    	}
    	return answer;
    }
    
}
