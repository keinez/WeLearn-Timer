package com.unstoppable.wmp.timer;

import android.os.Bundle;
import android.app.Activity;
import android.view.Menu;

import android.app.Activity;
import android.widget.TextView;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.util.DisplayMetrics;
import android.view.Menu;
import android.view.View;
import android.widget.Button;


public class Stopwatch extends Activity {
    /** Called when the activity is first created. */
	
	private TextView tempTextView; //Temporary TextView 
	private Button tempBtn; //Temporary Button
	private Handler mHandler = new Handler();
	private long startTime; //Time when start button pressed
	private long elapsedTime; //Time that elapsed since start button pressed
	private final int REFRESH_RATE = 100; //Update every 10th of a second
	private String hours,minutes,seconds,milliseconds;//Strings to display
	private long secs,mins,hrs,msecs; // number of string values
	private boolean stopped = false;
	
    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_stopwatch);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.activity_stopwatch, menu);
        return true;
    }
    //Function ran when the start button is pressed
    public void startClick (View view){
    	showStopButton();
    	if(stopped){
    		startTime = System.currentTimeMillis() - elapsedTime;
    	}
    	else{
    		startTime = System.currentTimeMillis();
    	}
    	mHandler.removeCallbacks(startTimer);
        mHandler.postDelayed(startTimer, 0);
    }
    //Function ran when the stop button is pressed
    public void stopClick (View view){
    	hideStopButton();
    	mHandler.removeCallbacks(startTimer);
    	stopped = true;
    }
    //Function ran when the reset button is pressed
    public void resetClick (View view){
    	stopped = false;
    	((TextView)findViewById(R.id.timer)).setText("00:00:00");
   // 	((TextView)findViewById(R.id.timerMs)).setText(".0");
    }
    
    public void lapClick (View view){
    	
    }
    
    //Used to show the stop button and hide the reset and start button
    private void showStopButton(){
        ((Button)findViewById(R.id.startButton)).setVisibility(View.GONE);
        ((Button)findViewById(R.id.resetButton)).setVisibility(View.GONE);
        ((Button)findViewById(R.id.stopButton)).setVisibility(View.VISIBLE);
        ((Button)findViewById(R.id.lapButton)).setVisibility(View.VISIBLE);
    }

  //Used to hide the stop button and show the reset and start button
    private void hideStopButton(){
        ((Button)findViewById(R.id.startButton)).setVisibility(View.VISIBLE);
        ((Button)findViewById(R.id.resetButton)).setVisibility(View.VISIBLE);
        ((Button)findViewById(R.id.stopButton)).setVisibility(View.GONE);
        ((Button)findViewById(R.id.lapButton)).setVisibility(View.GONE);
    }
    
    //Does the math to break up the miliseconds into hours, minutes
    //and seconds, and puts them into a string
    private void updateTimer (float time){
		secs = (long)(time/1000);
		mins = (long)((time/1000)/60);
		hrs = (long)(((time/1000)/60)/60);

		/* Convert the seconds to String
		 * and format to ensure it has
		 * a leading zero when required
		 */
		secs = secs % 60;
		seconds=String.valueOf(secs);
    	if(secs == 0){
    		seconds = "00";
    	}
    	if(secs <10 && secs > 0){
    		seconds = "0"+seconds;
    	}

		/* Convert the minutes to String and format the String */

    	mins = mins % 60;
		minutes=String.valueOf(mins);
    	if(mins == 0){
    		minutes = "00";
    	}
    	if(mins <10 && mins > 0){
    		minutes = "0"+minutes;
    	}

    	/* Convert the hours to String and format the String */

    	hours=String.valueOf(hrs);
    	if(hrs == 0){
    		hours = "00";
    	}
    	if(hrs <10 && hrs > 0){
    		hours = "0"+hours;
    	}

    	/* Although we are not using milliseconds on the timer in this example
    	 * I included the code in the event that you wanted to include it on your own
    	 */
    	String milliseconds = String.valueOf((long)time);
    	if(milliseconds.length()==2){
    		milliseconds = "0"+milliseconds;
    	}
      	if(milliseconds.length()<=1){
    		milliseconds = "00";
    	}
		milliseconds = milliseconds.substring(milliseconds.length()-3, milliseconds.length()-2);

		/* Setting the timer text to the elapsed time */
		((TextView)findViewById(R.id.timer)).setText(hours + ":" + minutes + ":" + seconds);
	//	((TextView)findViewById(R.id.timerMs)).setText("." + milliseconds);
	}
    
    private Runnable startTimer = new Runnable() {
    	   public void run() {
    		   elapsedTime = System.currentTimeMillis() - startTime;
    		   updateTimer(elapsedTime);
    		   mHandler.postDelayed(this,REFRESH_RATE);
    		}
    	};
}