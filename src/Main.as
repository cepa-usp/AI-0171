package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.filters.ColorMatrixFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexandre
	 */
	public class Main extends BaseMain
	{
		private const PAR:String = "par";
		private const IMPAR:String = "impar";
		private const INDEFINIDA:String = "indefinida";
		
		private var graph:SimpleGraph;
		private var xmin:Number;
		private var xmax:Number;
		
		private var funcVermelha:GraphFunction;
		private var funcVerde:GraphFunction;
		private var styleVermelha:DataStyle = new DataStyle();
		private var styleVerde:DataStyle = new DataStyle();
		
		private var funcoes:Vector.<Function> = new Vector.<Function>;
		private var funcoes_pares:Vector.<Function> = new Vector.<Function>;
		private var funcoes_impares:Vector.<Function> = new Vector.<Function>;
		
		private var respVermelho:Point = new Point();
		private var respVerde:Point = new Point();
		
		private var greyFormat:TextFormat = new TextFormat("Arial", 13, 0x8A8A8A);
		private var normalFormat:TextFormat = new TextFormat("Arial", 13, 0x000000);
		
		public function Main() 
		{
			
		}
		
		override protected function init():void 
		{
			createGraph();
			addListeners();
			sortVermelho();
			sortVerde();
			
			redA.restrict = "0123456789";
			redB.restrict = "0123456789";
			greenA.restrict = "0123456789";
			greenB.restrict = "0123456789";
			
			redA.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			redB.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			greenA.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			greenB.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			
			iniciaTutorial();
		}
		
		private function focusIn(e:FocusEvent):void 
		{
			var txt:TextField = TextField(e.target);
			txt.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			if (txt.text == "A" || txt.text == "B") {
				txt.defaultTextFormat = normalFormat;
				txt.text = "";
			}
		}
		
		private function focusOut(e:FocusEvent):void 
		{
			var txt:TextField = TextField(e.target);
			txt.removeEventListener(FocusEvent.FOCUS_OUT, focusOut);
			if (txt.text == "") {
				txt.defaultTextFormat = greyFormat;
				if (txt == redA) {
					txt.text = "A";
				}else if (txt == redB) {
					txt.text = "B";
				}else if (txt == greenA) {
					txt.text = "A";
				}else if (txt == greenB) {
					txt.text = "B";
				}
			}
		}
		
		private function createGraph():void 
		{
			xmin = 	-5.5;
			xmax = 	5.5;
			var xsize:Number = 	640;
			var ysize:Number = 	395;
			var yRange:Number = Math.abs((xmin - xmax) * ysize / xsize);
			var ymin:Number = 	-yRange / 2;
			var ymax:Number = 	yRange / 2;
			
			var tickSize:Number = 2;
			
			graph = new SimpleGraph(xmin, xmax, xsize, ymin, ymax, ysize);
			graph.x = ((stage.stageWidth - xsize) / 2) + 5;
			graph.y = 48;
			
			graph.enableTicks(SimpleGraph.AXIS_X, true);
			graph.enableTicks(SimpleGraph.AXIS_Y, true);
			graph.setTicksDistance(SimpleGraph.AXIS_X, tickSize);
			graph.setTicksDistance(SimpleGraph.AXIS_Y, tickSize);
			graph.setSubticksDistance(SimpleGraph.AXIS_X, tickSize / 2);
			graph.setSubticksDistance(SimpleGraph.AXIS_Y, tickSize / 2);
			graph.resolution = 0.1;
			graph.grid = true;
			graph.pan = true;
			graph.buttonMode = true;
			graph.addEventListener("initPan", startPan);
			
			layerAtividade.addChild(graph);
			graph.draw();
			
			//var graphBorder:Sprite = new Sprite();
			//graphBorder.graphics.lineStyle(1, 0x000000);
			//graphBorder.graphics.drawRect(0, 0, xsize, ysize);
			//graphBorder.x = graph.x;
			//graphBorder.y = graph.y;
			//addChild(graphBorder);
			
			styleVermelha.color = 0xFF0000;
			styleVermelha.alpha = 1;
			styleVermelha.stroke = 2;
			
			styleVerde.color = 0x008000;
			styleVerde.alpha = 1;
			styleVerde.stroke = 2;
		}
		
		private function startPan(e:Event):void 
		{
			graph.addEventListener("stopPan", stopPan);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, panning);
		}
		
		private function panning(e:MouseEvent):void 
		{
			xmin = graph.xmin;
			xmax = graph.xmax;
			funcVermelha.xmin = xmin;
			funcVerde.xmin = xmin;
			funcVermelha.xmax = xmax;
			funcVerde.xmax = xmax;
		}
		
		private function stopPan(e:Event):void 
		{
			graph.removeEventListener("stopPan", stopPan);
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, panning);
			panning(null);
		}
		
		private function addListeners():void 
		{
			finalizaVermelha.addEventListener(MouseEvent.CLICK, finalVermelho);
			finalizaVerde.addEventListener(MouseEvent.CLICK, finalVerde);
			
			reiniciaVermelha.addEventListener(MouseEvent.CLICK, sortVermelho);
			reiniciaVerde.addEventListener(MouseEvent.CLICK, sortVerde);
		}
		
		private function sortVermelho(e:MouseEvent = null):void 
		{
			if (funcVermelha != null) graph.removeFunction(funcVermelha);
			
			funcVermelha = getFunctionVermelha();
			
			graph.addFunction(funcVermelha, styleVermelha);
			
			graph.draw();
			
			certoErradoVermelho.visible = false;
			respostaVermelho.visible = false;
			resetRedTxt();
				
			lock(reiniciaVermelha);
			unlock(finalizaVermelha);
		}
		
		private function resetRedTxt():void
		{
			TextField(redA).defaultTextFormat = greyFormat;
			TextField(redB).defaultTextFormat = greyFormat;
			redA.text = "A";
			redB.text = "B";
			TextField(redA).selectable = true;
			TextField(redB).selectable = true;
		}
		
		private function sortVerde(e:MouseEvent = null):void 
		{
			if (funcVerde != null) graph.removeFunction(funcVerde);
			
			funcVerde = getFunctionVerde();
			
			graph.addFunction(funcVerde, styleVerde);
			
			graph.draw();
			
			certoErradoVerde.visible = false;
			respostaVerde.visible = false;
			resetGreenTxt();
			
			lock(reiniciaVerde);
			unlock(finalizaVerde);
		}
		
		private function resetGreenTxt():void
		{
			TextField(greenA).defaultTextFormat = greyFormat;
			TextField(greenB).defaultTextFormat = greyFormat;
			greenA.text = "A";
			greenB.text = "B";
			TextField(greenA).selectable = true;
			TextField(greenB).selectable = true;
		}
		
		private function getFunctionVermelha():GraphFunction 
		{
			var sortA:int = Math.floor(Math.random() * 10) * (Math.random() > 0.5 ? 1 : -1);
			var sortB:int = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			
			var f:Function = function(x:Number):Number {
				return sortA * x + sortB;
			}
			
			respVermelho.x = sortA;
			respVermelho.y = sortB;
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, f);
			
			return func;
		}
		
		private function getFunctionVerde():GraphFunction 
		{
			var sortA:int = Math.floor(Math.random() * 10) * (Math.random() > 0.5 ? 1 : -1);
			var sortB:int = Math.floor(Math.random() * 10) * (Math.random() > 0.5 ? 1 : -1);
			
			var f:Function = function(x:Number):Number {
				return sortA * x + sortB;
			}
			
			respVerde.x = sortA;
			respVerde.y = sortB;
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, f);
			
			return func;
		}
		
		private function finalVermelho(e:MouseEvent = null):void
		{
			if(redA.text != "A" && redB.text != "B"){
				var respA:int = int(redA.text);
				var respB:int = int(redB.text);
				
				if (respA == respVermelho.x && respB == respVermelho.y) {
					//Certo
					certoErradoVermelho.gotoAndStop(2);
				}else {
					//Errado
					certoErradoVermelho.gotoAndStop(1);
					respostaVermelho.resp.text = "Resposta: y(x)=" + respVermelho.x + "x" + (respVermelho.y >= 0 ? "+": "") + respVermelho.y;
					respostaVermelho.visible = true;
				}
				certoErradoVermelho.visible = true;
				TextField(redA).selectable = false;
				TextField(redB).selectable = false;
				unlock(reiniciaVermelha);
				lock(finalizaVermelha);
			}else {
				feedbackScreen.setText("Você precisa preencher os 2 campos antes de avaliar.");
			}
		}
		
		private function finalVerde(e:MouseEvent = null):void
		{
			if(greenA.text != "A" && greenB.text != "B"){
				var respA:int = int(greenA.text);
				var respB:int = int(greenB.text);
				
				if (respA == respVerde.x && respB == respVerde.y) {
					//Certo
					certoErradoVerde.gotoAndStop(2);
				}else {
					//Errado
					certoErradoVerde.gotoAndStop(1);
					respostaVerde.resp.text = "Resposta: y(x)=" + respVerde.x + "x" + (respVerde.y >= 0 ? "+" : "") + respVerde.y;
					respostaVerde.visible = true;
				}
				certoErradoVerde.visible = true;
				TextField(greenA).selectable = false;
				TextField(greenB).selectable = false;
				unlock(reiniciaVerde);
				lock(finalizaVerde);
			}else {
				feedbackScreen.setText("Você precisa preencher os 2 campos antes de avaliar.");
			}
		}
		
		//---------------- Tutorial -----------------------
		
		private var balao:CaixaTexto;
		private var pointsTuto:Array;
		private var tutoBaloonPos:Array;
		private var tutoPos:int;
		private var tutoSequence:Array;
		
		override public function iniciaTutorial(e:MouseEvent = null):void  
		{
			blockAI();
			
			tutoPos = 0;
			if(balao == null){
				balao = new CaixaTexto();
				layerTuto.addChild(balao);
				balao.visible = false;
				
				tutoSequence = ["Veja aqui as orientações.",
								"São apresentadas duas retas (vermelha e verde) no plano cartesiano...",
								"você pode arrastá-lo para melhor visualização dos pontos.",
								"Digite os valores de A e B na equação da reta vermelha...",
								"e os valores de A e B na equação da reta verde.",
								"Ao finalizar clique em avaliar.",
								"Pressione \"Nove reta\" para sortear uma nova equação."];
				
				pointsTuto = 	[new Point(650, 535),
								new Point(200 , 250),
								new Point(200 , 300),
								new Point(165 , 470),
								new Point(495 , 470),
								new Point(200 , 475),
								new Point(200 , 400)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.LAST],
								["", ""],
								["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								["", ""],
								["", ""]];
			}
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			
			balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
			balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			balao.addEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			balao.addEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
		}
		
		private function closeBalao(e:Event):void 
		{
			tutoPos++;
			if (tutoPos >= tutoSequence.length) {
				balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
				balao.visible = false;
				iniciaAi(null);
			}else {
				balao.setText(tutoSequence[tutoPos], tutoBaloonPos[tutoPos][0], tutoBaloonPos[tutoPos][1]);
				balao.setPosition(pointsTuto[tutoPos].x, pointsTuto[tutoPos].y);
			}
		}
		
		private function iniciaAi(e:BaseEvent):void 
		{
			balao.removeEventListener(BaseEvent.CLOSE_BALAO, iniciaAi);
			balao.removeEventListener(BaseEvent.NEXT_BALAO, closeBalao);
			unblockAI();
		}
		
	}

}