package 
{
	import BaseAssets.BaseMain;
	import BaseAssets.events.BaseEvent;
	import BaseAssets.tutorial.CaixaTexto;
	import cepa.graph.DataStyle;
	import cepa.graph.GraphFunction;
	import cepa.graph.rectangular.SimpleGraph;
	import com.eclecticdesignstudio.motion.Actuate;
	import com.eclecticdesignstudio.motion.easing.Elastic;
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
	import flash.text.TextFormatAlign;
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
		
		private var greyFormatA:TextFormat = new TextFormat("Times New Roman", 13, 0x8A8A8A);
		private var greyFormatB:TextFormat = new TextFormat("Times New Roman", 13, 0x8A8A8A);
		private var normalFormat:TextFormat = new TextFormat("Times New Roman", 13, 0x000000);
		
		public function Main() 
		{
			
		}
		
		private var widHeiRelacao:Point = new Point();
		override protected function init():void 
		{
			greyFormatA.align = TextFormatAlign.RIGHT;
			greyFormatB.align = TextFormatAlign.LEFT;
			
			layerDialogo.addChild(escolheRelacao);
			//widHeiRelacao.x = escolheRelacao.width;
			//widHeiRelacao.y = escolheRelacao.height;
			escolheRelacao.visible = false;
			escolheRelacao.alpha = 0;
			//escolheRelacao.scaleX = 0;
			//escolheRelacao.scaleY = 0;
			//escolheRelacao.width = 0;
			//escolheRelacao.height = 0;
			
			createGraph();
			addListeners();
			sortVermelho();
			sortVerde();
			
			redA.restrict = "\\-0123456789.,";
			redB.restrict = "\\-0123456789.,";
			greenA.restrict = "\\-0123456789.,";
			greenB.restrict = "\\-0123456789.,";
			
			redA.tabIndex = 1;
			redB.tabIndex = 2;
			finalizaVermelha.tabIndex = 3;
			greenA.tabIndex = 4;
			greenB.tabIndex = 5;
			finalizaVerde.tabIndex = 6;
			
			redA.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			redB.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			greenA.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			greenB.addEventListener(FocusEvent.FOCUS_IN, focusIn);
			
			redA.addEventListener(Event.CHANGE, changeText);
			redB.addEventListener(Event.CHANGE, changeText);
			greenA.addEventListener(Event.CHANGE, changeText);
			greenB.addEventListener(Event.CHANGE, changeText);
			
			iniciaTutorial();
		}
		
		private var txtRegExp:RegExp = /^-?[0-9]*[.,]?[0-9]*/;
		private function changeText(e:Event):void 
		{
			var txt:TextField = TextField(e.target);
			//trace(txtRegExp.exec(txt.text));
			txt.text = txtRegExp.exec(txt.text);
		}
		
		private function focusIn(e:FocusEvent):void 
		{
			var txt:TextField = TextField(e.target);
			txt.addEventListener(FocusEvent.FOCUS_OUT, focusOut);
			if (txt.text == "a" || txt.text == "b") {
				txt.defaultTextFormat = normalFormat;
				txt.text = "";
				//txt.restrict = "\\-0123456789";
			}
		}
		
		private function focusOut(e:FocusEvent):void 
		{
			var txt:TextField = TextField(e.target);
			txt.removeEventListener(FocusEvent.FOCUS_OUT, focusOut);
			if (txt.text == "") {
				if (txt == redA) {
					txt.defaultTextFormat = greyFormatA;
					txt.text = "a";
				}else if (txt == redB) {
					txt.defaultTextFormat = greyFormatB;
					txt.text = "b";
				}else if (txt == greenA) {
					txt.defaultTextFormat = greyFormatA;
					txt.text = "a";
				}else if (txt == greenB) {
					txt.defaultTextFormat = greyFormatB;
					txt.text = "b";
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
			graph.setAxesNameFormat(new TextFormat("arial", 12, 0x000000));
			graph.setAxisName(SimpleGraph.AXIS_X, "x");
			graph.setAxisName(SimpleGraph.AXIS_Y, "Y");
			
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
			
			reiniciaVermelha.addEventListener(MouseEvent.CLICK, openEscolheRelacao);
			reiniciaVerde.addEventListener(MouseEvent.CLICK, openEscolheRelacao);
			
			escolheRelacao.okBtn.addEventListener(MouseEvent.CLICK, okEscolheRelacao);
			escolheRelacao.cancelBtn.addEventListener(MouseEvent.CLICK, cancelEscolheRelacao);
		}
		
		private function okEscolheRelacao(e:MouseEvent):void 
		{
			if (escolheRelacao.nenhum.selected) {
				sortFunc();
			}else if (escolheRelacao.paralelas.selected) {
				sortFunc("paralelas");
			}else {
				sortFunc("perpendiculares");
			}
			
			escolheRelacao.visible = false;
			Actuate.tween(glassPane, 0.4, { /*scaleX:1, scaleY:1*/alpha:0 } );
			//Actuate.tween(escolheRelacao, 0.6, { width:0, height:0 } ).ease(Elastic.easeOut);
			Actuate.tween(escolheRelacao, 0.6, { alpha:0} );
		}
		
		private function cancelEscolheRelacao(e:MouseEvent):void 
		{
			escolheRelacao.visible = false;
			Actuate.tween(glassPane, 0.4, { /*scaleX:1, scaleY:1*/alpha:0 } );
			//Actuate.tween(escolheRelacao, 0.6, { width:0, height:0 } ).ease(Elastic.easeOut);
			Actuate.tween(escolheRelacao, 0.6, { alpha:0} );
		}
		
		private var sortFunc:Function;
		private function openEscolheRelacao(e:MouseEvent):void
		{
			if (e.target == reiniciaVermelha) {
				if (respVerde.x == 0) {
					sortVermelho();
					return;
				}
				sortFunc = sortVermelho;
			}else {
				if (respVermelho.x == 0) {
					sortVerde();
					return;
				}
				sortFunc = sortVerde;
			}
			
			escolheRelacao.nenhum.selected = true;
			escolheRelacao.visible = true;
			Actuate.tween(glassPane, 0.4, { /*scaleX:1, scaleY:1*/alpha:1 } );
			//Actuate.tween(escolheRelacao, 0.6, { width:widHeiRelacao.x, height:widHeiRelacao.y } ).ease(Elastic.easeOut);
			Actuate.tween(escolheRelacao, 0.6, { alpha:1} );
		}
		
		private function sortVermelho(relacao:String = "nenhum"):void 
		{
			if (funcVermelha != null) graph.removeFunction(funcVermelha);
			
			funcVermelha = getFunctionVermelha(relacao);
			
			graph.addFunction(funcVermelha, styleVermelha);
			
			graph.draw();
			
			certoErradoVermelho.visible = false;
			respostaVermelho.visible = false;
			resetRedTxt();
				
			lock(reiniciaVermelha);
			//unlock(finalizaVermelha);
		}
		
		private function resetRedTxt():void
		{
			TextField(redA).defaultTextFormat = greyFormatA;
			TextField(redB).defaultTextFormat = greyFormatB;
			redA.text = "a";
			redB.text = "b";
			TextField(redA).selectable = true;
			TextField(redA).mouseEnabled = true;
			TextField(redB).selectable = true;
			TextField(redB).mouseEnabled = true;
		}
		
		private function sortVerde(relacao:String = "nenhum"):void 
		{
			if (funcVerde != null) graph.removeFunction(funcVerde);
			
			funcVerde = getFunctionVerde(relacao);
			
			graph.addFunction(funcVerde, styleVerde);
			
			graph.draw();
			
			certoErradoVerde.visible = false;
			respostaVerde.visible = false;
			resetGreenTxt();
			
			lock(reiniciaVerde);
			//unlock(finalizaVerde);
		}
		
		private function resetGreenTxt():void
		{
			TextField(greenA).defaultTextFormat = greyFormatA;
			TextField(greenB).defaultTextFormat = greyFormatB;
			greenA.text = "a";
			greenB.text = "b";
			TextField(greenA).selectable = true;
			TextField(greenA).mouseEnabled = true;
			TextField(greenB).selectable = true;
			TextField(greenB).mouseEnabled = true;
		}
		
		private function getFunctionVermelha(relacao:String):GraphFunction 
		{
			var sortA:Number;
			var sortB:int;
			
			if(relacao == "nenhum"){
				sortA = Math.floor(Math.random() * 10) * (Math.random() > 0.5 ? 1 : -1);
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}else if (relacao == "paralelas") {
				sortA = respVerde.x;
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}else {
				sortA = -1 / respVerde.x;
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}
			
			var f:Function = function(x:Number):Number {
				return sortA * x + sortB;
			}
			
			respVermelho.x = sortA;
			respVermelho.y = sortB;
			
			var func:GraphFunction = new GraphFunction(xmin, xmax, f);
			
			return func;
		}
		
		private function getFunctionVerde(relacao:String):GraphFunction 
		{
			var sortA:Number;
			var sortB:int;
			
			if(relacao == "nenhum"){
				sortA = Math.floor(Math.random() * 10) * (Math.random() > 0.5 ? 1 : -1);
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}else if (relacao == "paralelas") {
				sortA = respVermelho.x;
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}else {
				sortA = -1 / respVermelho.x;
				sortB = Math.floor(Math.random() * 5) * (Math.random() > 0.5 ? 1 : -1);
			}
			
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
			if(redA.text != "a" && redB.text != "b"){
				var respA:Number = Number(redA.text.replace(",", "."));
				var respB:Number = Number(redB.text.replace(",", "."));
				var feed:String = "";
				
				if (respA == respVermelho.x && respB == respVermelho.y) {
					//Certo
					feed = "Correto!";
					certoErradoVermelho.gotoAndStop(2);
				}else {
					//Errado
					certoErradoVermelho.gotoAndStop(1);
					respostaVermelho.resp.text = "Resposta: y(x) = " + respVermelho.x + "x" + (respVermelho.y >= 0 ? "+": "") + respVermelho.y;
					respostaVermelho.visible = true;
					
					if (respA != respVermelho.x && respB != respVermelho.y) {
						//Errou os 2
						feed = "Ops! A resposta esperada é y(x) = " + respVermelho.x + "x" + (respVermelho.y >= 0 ? "+": "") + respVermelho.y + ", ou seja, tanto o coeficiente linear como o angular estão errados. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se:\n- O coeficiente linear é igual ao valor da função em x = 0, isto é, quando ela cruza o eixo y.\n- O coeficiente angular de uma função do primeiro grau é igual à inclinação da reta com relação ao eixo x, definida como Δy/Δx."
					}else if (respA == respVermelho.x) {
						//Acertou a
						feed = "Ops! A resposta esperada é y(x) = " + respVermelho.x + "x" + (respVermelho.y >= 0 ? "+": "") + respVermelho.y + ", ou seja, o coeficiente LINEAR está errado. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se: o coeficiente linear é igual ao valor da função em x = 0, isto é, quando ela cruza o eixo y";
					}else {
						//Acertou b
						feed = "Ops! A resposta esperada é y(x) = " + respVermelho.x + "x" + (respVermelho.y >= 0 ? "+": "") + respVermelho.y + ", ou seja, o coeficiente ANGULAR está errado. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se: o coeficiente angular de uma função do primeiro grau é igual à inclinação da reta com relação ao eixo x, definida como Δy/Δx."
					}
				}
				feedbackScreen.setText(feed);
				
				stage.focus = null;
				certoErradoVermelho.visible = true;
				TextField(redA).selectable = false;
				TextField(redA).mouseEnabled = false;
				TextField(redB).selectable = false;
				TextField(redB).mouseEnabled = false;
				unlock(reiniciaVermelha);
				//lock(finalizaVermelha);
			}else {
				feedbackScreen.setText("Informe ambos os coeficientes linear e angular para avaliar.");
			}
		}
		
		private function finalVerde(e:MouseEvent = null):void
		{
			if(greenA.text != "a" && greenB.text != "b"){
				var respA:Number = Number(greenA.text.replace(",", "."));
				var respB:Number = Number(greenB.text.replace(",", "."));
				var feed:String = "";
				
				if (respA == respVerde.x && respB == respVerde.y) {
					//Certo
					feed = "Correto!";
					certoErradoVerde.gotoAndStop(2);
				}else {
					//Errado
					certoErradoVerde.gotoAndStop(1);
					respostaVerde.resp.text = "Resposta: y(x) = " + respVerde.x + "x" + (respVerde.y >= 0 ? "+" : "") + respVerde.y;
					respostaVerde.visible = true;
					
					if (respA != respVerde.x && respB != respVerde.y) {
						//Errou os 2
						feed = "Ops! A resposta esperada é y(x) = " + respVerde.x + "x" + (respVerde.y >= 0 ? "+" : "") + respVerde.y + ", ou seja, tanto o coeficiente linear como o angular estão errados. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se:\n- O coeficiente linear é igual ao valor da função em x = 0, isto é, quando ela cruza o eixo y.\n- O coeficiente angular de uma função do primeiro grau é igual à inclinação da reta com relação ao eixo x, definida como Δy/Δx."
					}else if (respA == respVerde.x) {
						//Acertou a
						feed = "Ops! A resposta esperada é y(x) = " + respVerde.x + "x" + (respVerde.y >= 0 ? "+" : "") + respVerde.y + ", ou seja, o coeficiente LINEAR está errado. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se: o coeficiente linear é igual ao valor da função em x = 0, isto é, quando ela cruza o eixo y";
					}else {
						//Acertou b
						feed = "Ops! A resposta esperada é y(x) = " + respVerde.x + "x" + (respVerde.y >= 0 ? "+" : "") + respVerde.y + ", ou seja, o coeficiente ANGULAR está errado. Compare sua resposta com a esperada (ela será exibida junto da sua), reveja o gráfico e lembre-se: o coeficiente angular de uma função do primeiro grau é igual à inclinação da reta com relação ao eixo x, definida como Δy/Δx."
					}
				}
				feedbackScreen.setText(feed);
				
				stage.focus = null;
				certoErradoVerde.visible = true;
				TextField(greenA).selectable = false;
				TextField(greenA).mouseEnabled = false;
				TextField(greenB).selectable = false;
				TextField(greenB).mouseEnabled = false;
				unlock(reiniciaVerde);
				//lock(finalizaVerde);
			}else {
				feedbackScreen.setText("Informe ambos os coeficientes linear e angular para avaliar.");
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
								"Os gráficos de duas funções do primeiro grau, escolhidas aleatoriamente pelo software, são exibidos aqui (uma em vermelho e outra em verde).",
								"Caso não esteja vendo algum desses gráficos, arraste o plano cartesiano para cima ou para baixo.",
								"Analise os gráficos acima e, com base neles, indique nos campos apropriados abaixo os valores dos coeficientes linear e angular.",
								"Pressione \"avaliar\" para verificar sua resposta.",
								"Pressione \"nova reta\" para que o software exiba um novo gráfico.",
								"Faça o mesmo para a reta verde.",
								"Pressione este botão para reiniciar este tutorial."];
				
				pointsTuto = 	[new Point(650, 535),
								new Point(180 , 180),
								new Point(250 , 250),
								new Point(165 , 475),
								new Point(170 , 564),
								new Point(262 , 564),
								new Point(490 , 475),
								new Point(650 , 490)];
								
				tutoBaloonPos = [[CaixaTexto.RIGHT, CaixaTexto.LAST],
								["", ""],
								["", ""],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.FIRST],
								[CaixaTexto.BOTTON, CaixaTexto.CENTER],
								[CaixaTexto.BOTTON, CaixaTexto.LAST],
								[CaixaTexto.RIGHT, CaixaTexto.CENTER]];
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