package;

#if android
import android.Permissions;
import android.os.Build.VERSION;
import android.os.Environment;
#end
import flash.system.System;
import flixel.FlxG;
import flixel.util.FlxStringUtil;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.io.Path;
import lime.app.Application;
import openfl.events.UncaughtErrorEvent;
import openfl.utils.Assets as OpenFlAssets;
import openfl.Lib;
import sys.FileSystem;
import sys.io.File;

/**
 * ...
 * @author: Saw (M.A. Jigsaw)
 */
class SUtil
{
	public static function getPath():String
	{
		#if android
		return Environment.getExternalStorageDirectory() + '/' + '.' + Application.current.meta.get('file') + '/';
		#else
		return '';
		#end
	}

	/**
	 * Uncaught error handler original made by: sqirra-rng
	 */
	public static function uncaughtErrorHandler()
	{
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, function(u:UncaughtErrorEvent)
		{
			var callStack:Array<StackItem> = CallStack.exceptionStack(true);
			var errMsg:String = '';

			for (stackItem in callStack)
			{
				switch (stackItem)
				{
					case FilePos(s, file, line, column):
						errMsg += file + ' (line ' + line + ')\n';
					default:
						Sys.println(stackItem);
				}
			}

			errMsg += u.error;

			Sys.println(errMsg);
			SUtil.applicationAlert('Error!', errMsg);

			try
			{
				if (!FileSystem.exists(SUtil.getPath() + 'crash/'))
					FileSystem.createDirectory(SUtil.getPath() + 'crash/');

				File.saveContent(SUtil.getPath() + 'crash/' + Application.current.meta.get('file') + '_' + FlxStringUtil.formatTime(Sys.time(), true) + '.log', errMsg + "\n");
			}
			catch (e:Dynamic)
				SUtil.applicationAlert('Error!', "Clouldn't save the crash dump because: " + e);

			System.exit(1);
		});
	}

	static function applicationAlert(title:String, description:String)
	{
		Application.current.window.alert(description, title);
	}

	#if android
	public static function saveContent(fileName:String = 'file', fileExtension:String = '.json', fileData:String = 'you forgot to add something in your code')
	{
		try
		{
			if (!FileSystem.exists(SUtil.getPath() + 'saves/'))
				FileSystem.createDirectory(SUtil.getPath() + 'saves/');

			File.saveContent(SUtil.getPath() + 'saves/' + fileName + fileExtension, fileData);
			SUtil.applicationAlert('Done!', 'File Saved Successfully!');
		}
		catch (e:Dynamic)
			SUtil.applicationAlert('Error!', "Clouldn't save the file because: " + e);
	}

	public static function copyContent(copyPath:String, savePath:String)
	{
		try
		{
			if (!FileSystem.exists(savePath))
				File.saveBytes(savePath, OpenFlAssets.getBytes(copyPath));
		}
		catch (e:Dynamic)
			SUtil.applicationAlert('Error!', "Clouldn't copy the file because: " + e);
	}
	#end
}