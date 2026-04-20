//
// Copyright (c) 2026 Robert Weber,Leo Germer, Andreas Hofmann and contributors
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

within ;
package TranslatorModelle

  package Components

    model AbsolutePotential "Measure voltage against ground"

      outer parameter Modelica.Units.SI.Voltage GLOBAL_START_POTENTIAL_HIGH;

      extends Modelica.Icons.RoundSensor;

      Modelica.Electrical.Analog.Interfaces.Pin pin_p annotation (
          Placement(transformation(extent={{-118,-16},{-84,18}}),
            iconTransformation(extent={{-118,-16},{-84,18}})));

      Modelica.Electrical.Analog.Sensors.VoltageSensor voltageSensor
        "Voltage sensor" annotation (Placement(transformation(extent={{-12,12},{12,-12}},
            rotation=0)));

      Modelica.Electrical.Analog.Basic.Ground ground
        "Ground" annotation (Placement(transformation(extent={{16,-88},{44,-60}})));

      Modelica.Blocks.Interfaces.RealOutput potential(unit="V")
        "Absolute potential (i.e. voltage against ground)" annotation (Placement(transformation(extent={{192,-10},
                {212,10}}), iconTransformation(extent={{192,-10},{212,10}})));

      Modelica.Blocks.Continuous.FirstOrder firstOrder(
        T = 1e-7)                              annotation (Placement(transformation(extent={{90,-10},{110,10}})));

    equation
      connect(pin_p, voltageSensor.p) annotation (Line(points={{-101,1},{-100,1},{-100,
              0},{-12,0}}, color={0,0,255}));
      connect(voltageSensor.n, ground.p) annotation (Line(points={{12,0},{30,0},{30,-60}}, color={0,0,255}));

      connect(voltageSensor.v, firstOrder.u) annotation (Line(points={{0,13.2},{0,
              20},{60,20},{60,0},{88,0}}, color={0,0,127}));
      connect(firstOrder.y, potential)
        annotation (Line(points={{111,0},{202,0}}, color={0,0,127}));
      annotation (Icon(coordinateSystem(
            preserveAspectRatio=true,
            extent={{-100,-140},{200,100}}), graphics={
            Rectangle(extent={{-100,100},{200,-140}}, lineColor={0,0,0}),
            Line(points={{-70,0},{-90,0}}, color={0,0,255}),
            Line(points={{70,0},{120,0}},color={0,0,255}),
            Text(
              extent={{-100,72},{200,98}},
              textString="%name",
              textColor={0,0,255}),
            Text(
              extent={{-32,-6},{28,-66}},
              textString="V",
              textColor={64,64,64}),
            Line(points={{100,-134},{140,-134}},
                                            color={0,0,255}),
            Line(points={{80,-114},{160,-114}},
                                            color={0,0,255}),
            Line(points={{60,-94},{180,-94}},
                                            color={0,0,255}),
            Line(points={{120,0},{120,-94}},
                                         color={0,0,255})}),
                                       Diagram(
            coordinateSystem(preserveAspectRatio=false, extent={{-100,-140},{
                200,100}})));
    end AbsolutePotential;

    model Consumer_TInput
       Modelica.Electrical.Analog.Basic.VariableResistor consumerResistor annotation (Placement(transformation(extent={{20,-22},
                {44,2}})));
      Modelica.Blocks.Sources.BooleanStep startShortCircuit(startTime=1000)
        annotation (Placement(transformation(extent={{-128,42},{-108,62}})));
      Modelica.Blocks.Continuous.Derivative derivative(initType=Modelica.Blocks.Types.Init.InitialState)
        annotation (Placement(transformation(extent={{46,40},{66,60}})));
      Consumer.Resistance_ShortCircuit resistance_ShortCircuit_TL
        annotation (Placement(transformation(extent={{-22,32},{16,68}})));
      Modelica.Electrical.Analog.Basic.Capacitor capacitorC(C=1e-8)
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={-158,-26})));
      Modelica.Electrical.Analog.Basic.Resistor resistorRC(R=1e-8)
        annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=270,
            origin={-158,-58})));
      Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(
            transformation(extent={{-322,8},{-302,28}}),   iconTransformation(
              extent={{-354,20},{-334,40}})));
      Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(
            transformation(extent={{362,-20},{382,0}}),  iconTransformation(extent={{336,20},
                {356,40}})));
    equation
      connect(consumerResistor.n,n)  annotation (Line(points={{44,-10},{372,-10}},           color={0,0,255}));
      connect(startShortCircuit.y, resistance_ShortCircuit_TL.shortCircuitTrigger)
        annotation (Line(points={{-107,52},{-68,52},{-68,50.36},{-21.24,50.36}},
            color={255,0,255}));
      connect(resistance_ShortCircuit_TL.Rds,derivative. u)
        annotation (Line(points={{17.14,50},{44,50}},  color={0,0,127}));
      connect(consumerResistor.R,resistance_ShortCircuit_TL. Rds)
        annotation (Line(points={{32,4.4},{32,50},{17.14,50}}, color={0,0,127}));
      connect(resistorRC.p,capacitorC. n)
        annotation (Line(points={{-158,-48},{-158,-36}}, color={0,0,255}));
      connect(consumerResistor.p,p)  annotation (Line(points={{20,-10},{-270,-10},
              {-270,18},{-312,18}},
                              color={0,0,255}));
      connect(resistorRC.n,n)  annotation (Line(points={{-158,-68},{-160,-68},{
              -160,-80},{350,-80},{350,-10},{372,-10}},
                                               color={0,0,255}));
      connect(capacitorC.p,p)  annotation (Line(points={{-158,-16},{-158,-10},{
              -270,-10},{-270,18},{-312,18}},
                                       color={0,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-360,
                -100},{400,100}})), Diagram(coordinateSystem(preserveAspectRatio=
                false, extent={{-360,-100},{400,100}}), graphics={
            Text(
              extent={{72,60},{138,44}},
              textColor={255,255,255},
              textString="Current"),
            Rectangle(
              extent={{-34,86},{78,18}},
              fillColor={170,255,213},
              fillPattern=FillPattern.Solid,
              pattern=LinePattern.None,
              lineColor={102,44,145}),
            Rectangle(
              extent={{-282,6},{-58,-92}},
              lineColor={0,0,0},
              pattern=LinePattern.Dot,
              lineThickness=0.5),
            Text(
              extent={{-130,-62},{-66,-82}},
              textColor={0,0,0},
              textString="Input Circuit"),
            Rectangle(
              extent={{-148,74},{-68,32}},
              fillColor={170,255,170},
              fillPattern=FillPattern.Solid,
              pattern=LinePattern.None,
              lineColor={102,44,145}),
            Text(
              extent={{-112,76},{-62,60}},
              textColor={0,140,72},
              fontSize=6,
              textString="Short Circuit")}));
    end Consumer_TInput;

    package Consumer
      model Consumer_S4_PhiInput

        Modelica.Electrical.Analog.Basic.VariableResistor consumerResistor annotation (Placement(transformation(extent={{-12,-10},
                  {12,14}})));

        Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(
              transformation(extent={{-354,20},{-334,40}}),  iconTransformation(
                extent={{-354,20},{-334,40}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(
              transformation(extent={{330,-8},{350,12}}),  iconTransformation(extent={{336,20},
                  {356,40}})));
        Consumer_Rec consumer_S4_Rec
          annotation (Placement(transformation(extent={{210,84},{316,142}})));
        Modelica.Blocks.Sources.BooleanStep startShortCircuit(startTime=
              consumer_S4_Rec.scTime)
          annotation (Placement(transformation(extent={{-152,52},{-132,72}})));
        Resistance_ShortCircuit resistance_ShortCircuit_TL
          annotation (Placement(transformation(extent={{-48,48},{-10,82}})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC2(C=consumer_S4_Rec.C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-180,-8})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC2(R=consumer_S4_Rec.R_C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-180,-48})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC1(C=consumer_S4_Rec.C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-286,-8})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC1(R=consumer_S4_Rec.R_C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-286,-48})));
        Modelica.Electrical.Analog.Basic.Resistor resistorL(R=consumer_S4_Rec.R_L)
          annotation (Placement(transformation(extent={{-228,-8},{-208,12}})));
        Modelica.Electrical.Analog.Basic.Inductor inductorL(L=consumer_S4_Rec.L)
          annotation (Placement(transformation(extent={{-262,-8},{-242,12}})));
      equation
        connect(consumerResistor.n,n)  annotation (Line(points={{12,2},{340,2}},               color={0,0,255}));
        connect(startShortCircuit.y, resistance_ShortCircuit_TL.shortCircuitTrigger)
          annotation (Line(points={{-131,62},{-82,62},{-82,65.34},{-47.24,65.34}},
              color={255,0,255}));
        connect(resistance_ShortCircuit_TL.Rds, consumerResistor.R)
          annotation (Line(points={{-8.86,65},{0,65},{0,16.4}}, color={0,0,127}));
        connect(resistorRC2.p, capacitorC2.n) annotation (Line(points={{-180,
                -38},{-180,-18}},                 color={0,0,255}));
        connect(resistorRC1.p, capacitorC1.n)
          annotation (Line(points={{-286,-38},{-286,-18}}, color={0,0,255}));
        connect(p, capacitorC1.p) annotation (Line(points={{-344,30},{-322,30},{-322,
                2},{-286,2}}, color={0,0,255}));
        connect(resistorRC1.n, n) annotation (Line(points={{-286,-58},{-286,-68},
                {318,-68},{318,2},{340,2}},color={0,0,255}));
        connect(resistorRC2.n, n) annotation (Line(points={{-180,-58},{-180,-68},
                {318,-68},{318,2},{340,2}},color={0,0,255}));
        connect(resistorL.p, inductorL.n)
          annotation (Line(points={{-228,2},{-242,2}}, color={0,0,255}));
        connect(capacitorC1.p, inductorL.p)
          annotation (Line(points={{-286,2},{-262,2}}, color={0,0,255}));
        connect(resistorL.n, capacitorC2.p)
          annotation (Line(points={{-208,2},{-180,2}}, color={0,0,255}));
        connect(capacitorC2.p, consumerResistor.p)
          annotation (Line(points={{-180,2},{-12,2}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-340,-100},
                  {340,180}}), graphics={
              Rectangle(
                extent={{-340,180},{340,136}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor={236,236,236},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-340,132},{340,-100}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor=DynamicSelect({255,255,255}, if enableShortFunctionality then {255,200,175} else {255,255,255}),
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-330,122},{330,-86}},
                lineColor={28,108,200},
                lineThickness=0.5,
                pattern=LinePattern.Dash),
              Rectangle(
                extent={{68,52},{110,10}},
                fillColor={0,127,0},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={0,0,0}),
              Rectangle(
                extent={{110,52},{152,10}},
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5,
                pattern=LinePattern.None),
              Line(points={{30,30},{348,30}},color={0,0,0}),
              Line(points={{-346,30},{-140,30}},
                                               color={0,0,0}),
              Text(
                extent={{-284,178},{318,154}},
                lineColor={28,108,200},
                horizontalAlignment=TextAlignment.Left,
                textString=consumerData.fullNameOfConsumer,
                textStyle={TextStyle.Bold}),
              Text(
                extent={{-280,128},{218,52}},
                textColor={28,108,200},
                textString=String(consumerData.consumerClass)),
              Rectangle(
                extent={{-38,6},{-16,-34}},
                lineColor={28,108,200},
                lineThickness=1),
              Rectangle(
                extent={{-11,20},{11,-20}},
                lineColor={28,108,200},
                lineThickness=1,
                origin={-79,30},
                rotation=90),
              Line(
                points={{-40,-52},{-16,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-40,-58},{-16,-58}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-28,-34},{-28,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-28,-58},{-28,-76}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-60,30},{68,30}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-28,6},{-28,30}},
                color={28,108,200},
                thickness=1),
              Rectangle(
                extent={{-11,20},{11,-20}},
                lineColor={28,108,200},
                lineThickness=1,
                origin={-145,30},
                rotation=90,
                fillColor={28,108,200},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-124,30},{-100,30}},
                color={28,108,200},
                thickness=1),
              Rectangle(
                extent={{-202,6},{-180,-34}},
                lineColor={28,108,200},
                lineThickness=1),
              Line(
                points={{-204,-52},{-180,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-204,-58},{-180,-58}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-192,-34},{-192,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-192,-58},{-192,-76}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-192,6},{-192,30}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-306,30},{-164,30}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-192,-76},{-28,-76}},
                color={28,108,200},
                thickness=1)}), Diagram(coordinateSystem(preserveAspectRatio=false,
                extent={{-340,-100},{340,180}}), graphics={
              Text(
                extent={{40,72},{106,56}},
                textColor={255,255,255},
                textString="Current"),
              Rectangle(
                extent={{-94,98},{26,30}},
                fillColor={170,255,213},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Rectangle(
                extent={{-314,18},{-90,-80}},
                lineColor={0,0,0},
                pattern=LinePattern.Dot,
                lineThickness=0.5),
              Text(
                extent={{-160,20},{-96,0}},
                textColor={0,0,0},
                textString="Input Circuit"),
              Rectangle(
                extent={{-184,90},{-114,44}},
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Text(
                extent={{-156,94},{-106,78}},
                textColor={0,140,72},
                fontSize=6,
                textString="Short Circuit")}));
      end Consumer_S4_PhiInput;

      model Consumer_S4_TInput
         Modelica.Electrical.Analog.Basic.VariableResistor consumerResistor annotation (Placement(transformation(extent={{-12,-10},
                  {12,14}})));

        Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(
              transformation(extent={{-354,20},{-334,40}}),  iconTransformation(
                extent={{-354,20},{-334,40}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(
              transformation(extent={{330,-8},{350,12}}),  iconTransformation(extent={{336,20},
                  {356,40}})));
        Consumer_Rec consumer_S4_Rec
          annotation (Placement(transformation(extent={{210,84},{316,142}})));
        Modelica.Blocks.Sources.BooleanStep startShortCircuit(startTime=
              consumer_S4_Rec.scTime)
          annotation (Placement(transformation(extent={{-176,52},{-156,72}})));
        Modelica.Blocks.Continuous.Derivative derivative(initType=Modelica.Blocks.Types.Init.InitialState)
          annotation (Placement(transformation(extent={{14,52},{34,72}})));
        Resistance_ShortCircuit resistance_ShortCircuit_TL
          annotation (Placement(transformation(extent={{-62,44},{-18,80}})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC(C=consumer_S4_Rec.C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-190,-14})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC(R=consumer_S4_Rec.R_C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-190,-46})));
      equation
        connect(consumerResistor.n,n)  annotation (Line(points={{12,2},{340,2}},               color={0,0,255}));
        connect(startShortCircuit.y, resistance_ShortCircuit_TL.shortCircuitTrigger)
          annotation (Line(points={{-155,62},{-62,62},{-62,62.36},{-61.12,62.36}},
              color={255,0,255}));
        connect(resistance_ShortCircuit_TL.Rds, derivative.u)
          annotation (Line(points={{-16.68,62},{12,62}}, color={0,0,127}));
        connect(consumerResistor.R, resistance_ShortCircuit_TL.Rds)
          annotation (Line(points={{0,16.4},{0,62},{-16.68,62}}, color={0,0,127}));
        connect(resistorRC.p, capacitorC.n)
          annotation (Line(points={{-190,-36},{-190,-24}}, color={0,0,255}));
        connect(consumerResistor.p, p) annotation (Line(points={{-12,2},{-302,2},{-302,
                30},{-344,30}}, color={0,0,255}));
        connect(resistorRC.n, n) annotation (Line(points={{-190,-56},{-190,-68},
                {318,-68},{318,2},{340,2}},      color={0,0,255}));
        connect(capacitorC.p, p) annotation (Line(points={{-190,-4},{-190,2},{-302,
                2},{-302,30},{-344,30}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-340,-100},
                  {340,180}}), graphics={
              Rectangle(
                extent={{-340,180},{340,136}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor={236,236,236},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-340,132},{340,-100}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor=DynamicSelect({255,255,255}, if enableShortFunctionality then {255,200,175} else {255,255,255}),
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-330,122},{330,-86}},
                lineColor={28,108,200},
                lineThickness=0.5,
                pattern=LinePattern.Dash),
              Rectangle(
                extent={{68,52},{110,10}},
                fillColor={0,127,0},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={0,0,0}),
              Rectangle(
                extent={{110,52},{152,10}},
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5,
                pattern=LinePattern.None),
              Line(points={{30,30},{348,30}},color={0,0,0}),
              Line(points={{-346,30},{-140,30}},
                                               color={0,0,0}),
              Text(
                extent={{-284,178},{318,154}},
                lineColor={28,108,200},
                horizontalAlignment=TextAlignment.Left,
                textString=consumerData.fullNameOfConsumer,
                textStyle={TextStyle.Bold}),
              Text(
                extent={{-280,128},{218,52}},
                textColor={28,108,200},
                textString=String(consumerData.consumerClass)),
              Rectangle(
                extent={{-54,6},{-32,-34}},
                lineColor={28,108,200},
                lineThickness=1),
              Line(
                points={{-56,-52},{-32,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-56,-58},{-32,-58}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-44,-34},{-44,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-44,-58},{-44,-70}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-150,30},{66,30}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-44,6},{-44,30}},
                color={28,108,200},
                thickness=1)}), Diagram(coordinateSystem(preserveAspectRatio=false,
                extent={{-340,-100},{340,180}}), graphics={
              Text(
                extent={{40,72},{106,56}},
                textColor={255,255,255},
                textString="Current"),
              Rectangle(
                extent={{-66,98},{46,30}},
                fillColor={170,255,213},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Rectangle(
                extent={{-268,20},{-90,-80}},
                lineColor={0,0,0},
                pattern=LinePattern.Dot,
                lineThickness=0.5),
              Text(
                extent={{-162,-50},{-98,-70}},
                textColor={0,0,0},
                textString="Input Circuit"),
              Rectangle(
                extent={{-186,86},{-110,46}},
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Text(
                extent={{-156,90},{-106,74}},
                textColor={0,140,72},
                fontSize=6,
                textString="Short Circuit")}));
      end Consumer_S4_TInput;

      model Consumer_PhiInput
        Modelica.Electrical.Analog.Basic.VariableResistor consumerResistor annotation (Placement(transformation(extent={{-20,-30},
                  {4,-6}})));
        Modelica.Blocks.Sources.BooleanStep startShortCircuit(startTime=1000)
          annotation (Placement(transformation(extent={{-178,34},{-158,54}})));
        Resistance_ShortCircuit resistance_ShortCircuit_TL
          annotation (Placement(transformation(extent={{-64,24},{-18,62}})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC2(C=1e-8)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-190,-28})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC2(R=1e-8)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-190,-62})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC1(C=1e-8)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-294,-28})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC1(R=1e-8)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-294,-60})));
        Modelica.Electrical.Analog.Basic.Resistor resistorL(R=1e-8)
          annotation (Placement(transformation(extent={{-236,-28},{-216,-8}})));
        Modelica.Electrical.Analog.Basic.Inductor inductorL(L=1e-8)
          annotation (Placement(transformation(extent={{-270,-28},{-250,-8}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(
              transformation(extent={{-362,0},{-342,20}}),   iconTransformation(
                extent={{-354,20},{-334,40}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(
              transformation(extent={{322,-28},{342,-8}}), iconTransformation(extent={{336,20},
                  {356,40}})));
      equation
        connect(consumerResistor.n,n)  annotation (Line(points={{4,-18},{332,-18}},            color={0,0,255}));
        connect(startShortCircuit.y, resistance_ShortCircuit_TL.shortCircuitTrigger)
          annotation (Line(points={{-157,44},{-64,44},{-64,43.38},{-63.08,43.38}},
              color={255,0,255}));
        connect(resistance_ShortCircuit_TL.Rds,consumerResistor. R)
          annotation (Line(points={{-16.62,43},{-8,43},{-8,-3.6}},
                                                                color={0,0,127}));
        connect(resistorRC2.p,capacitorC2. n) annotation (Line(points={{-190,
                -52},{-190,-38}},                 color={0,0,255}));
        connect(resistorRC1.p,capacitorC1. n)
          annotation (Line(points={{-294,-50},{-294,-38}}, color={0,0,255}));
        connect(p,capacitorC1. p) annotation (Line(points={{-352,10},{-330,10},{-330,-18},
                {-294,-18}},  color={0,0,255}));
        connect(resistorRC1.n,n)  annotation (Line(points={{-294,-70},{-294,-88},{310,
                -88},{310,-18},{332,-18}}, color={0,0,255}));
        connect(resistorRC2.n,n)  annotation (Line(points={{-190,-72},{-190,-88},
                {310,-88},{310,-18},{332,-18}},
                                           color={0,0,255}));
        connect(resistorL.p,inductorL. n)
          annotation (Line(points={{-236,-18},{-250,-18}},
                                                       color={0,0,255}));
        connect(capacitorC1.p,inductorL. p)
          annotation (Line(points={{-294,-18},{-270,-18}},
                                                       color={0,0,255}));
        connect(resistorL.n,capacitorC2. p)
          annotation (Line(points={{-216,-18},{-190,-18}},
                                                       color={0,0,255}));
        connect(capacitorC2.p,consumerResistor. p)
          annotation (Line(points={{-190,-18},{-20,-18}},
                                                      color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-400,-100},
                  {380,100}})), Diagram(coordinateSystem(preserveAspectRatio=false,
                extent={{-400,-100},{380,100}}), graphics={
              Text(
                extent={{32,52},{98,36}},
                textColor={255,255,255},
                textString="Current"),
              Rectangle(
                extent={{-102,78},{18,10}},
                fillColor={170,255,213},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Rectangle(
                extent={{-322,-2},{-98,-100}},
                lineColor={0,0,0},
                pattern=LinePattern.Dot,
                lineThickness=0.5),
              Text(
                extent={{-170,0},{-106,-20}},
                textColor={0,0,0},
                textString="Input Circuit"),
              tangle(
                extent={{-174,70},{-122,24}},
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Rectangle(
                extent={{-192,64},{-116,24}},
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Text(
                extent={{-158,68},{-108,52}},
                textColor={0,140,72},
                fontSize=6,
                textString="Short Circuit")}));
      end Consumer_PhiInput;

      model Consumer_Rec
          extends Modelica.Icons.Record;

        parameter Modelica.Units.SI.Inductance L=1e-7 "Input inductance"  annotation (Dialog(group="Input Circuit Data"));
        parameter Modelica.Units.SI.Resistance R_L=1e-3 "Input resistor inductance" annotation (Dialog(group="Input Circuit Data"));

        parameter Modelica.Units.SI.Capacitance C1=1e-6 "Input capacitance C1" annotation (Dialog(group="Input Circuit Data"));
        parameter Modelica.Units.SI.Resistance R_C1=1e-3 "Input resistor capacitance R1" annotation (Dialog(group="Input Circuit Data"));

        parameter Modelica.Units.SI.Capacitance C2=1e-6 "Input capacitance C2 (also for T input circuit)" annotation (Dialog(group="Input Circuit Data"));
        parameter Modelica.Units.SI.Resistance R_C2=1e-3 "Input resistor capacitance C2 (also for T input circuit)" annotation (Dialog(group="Input Circuit Data"));

        parameter Modelica.Units.SI.Resistance R_consumer = 100 "Consumer resistance (static)" annotation (Dialog(group="Consumer Data"));
        parameter Real activation_factor = 1.0 "Factor is multiplied with the resistance of the consumer" annotation (Dialog(group="Conumser Data"));

        parameter Modelica.Units.SI.Time scTime = 5000 "Short circuit time" annotation (Dialog(group="Short Circuit Setting"));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end Consumer_Rec;

      model dummyLoad
        Modelica.Electrical.Analog.Sources.SignalCurrent signalCurrent annotation (Placement(transformation(extent={{-20,20},
                  {20,-20}})));
        Modelica.Blocks.Sources.Ramp rampAdditionalLoadCurrent(
          duration=0.1,
          height=0,
          startTime=5000)        annotation (Placement(transformation(extent={{-80,-60},
                  {-60,-40}})));
        Modelica.Blocks.Continuous.FirstOrder
                                     firstOrderCurrent(
          T=1e-6,
          initType=Modelica.Blocks.Types.Init.InitialState,
          y_start=rampAdditionalLoadCurrent.offset)   "for numerical stability" annotation (Placement(transformation(extent={{-40,-60},
                  {-20,-40}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(transformation(extent={{-110,
                  -10},{-90,10}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(transformation(extent={{90,-10},
                  {110,10}})));

      equation
        connect(rampAdditionalLoadCurrent.y,firstOrderCurrent. u) annotation (Line(points={{-59,-50},
                {-42,-50}},                                                                                            color={0,0,127}));
        connect(firstOrderCurrent.y,signalCurrent. i) annotation (Line(points={{-19,-50},
                {0,-50},{0,-24}},         color={0,0,127}));
        connect(p,signalCurrent. p) annotation (Line(points={{-100,0},{-20,0}}, color={0,0,255}));
        connect(signalCurrent.n,n)  annotation (Line(points={{20,0},{100,0}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,0},
                lineThickness=1,
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid), Text(
                extent={{-88,84},{100,-80}},
                textColor={0,0,0},
                textStyle={TextStyle.Bold},
                textString="L")}),                                     Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end dummyLoad;

      model Consumer_S4_Left_T_Input

           Modelica.Electrical.Analog.Basic.VariableResistor consumerResistor annotation (Placement(transformation(extent={{-12,-10},
                  {12,14}})));

        Modelica.Electrical.Analog.Interfaces.PositivePin p annotation (Placement(
              transformation(extent={{-354,20},{-334,40}}),  iconTransformation(
                extent={{-354,20},{-334,40}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin n annotation (Placement(
              transformation(extent={{330,-8},{350,12}}),  iconTransformation(extent={{336,20},
                  {356,40}})));
        Consumer_Rec consumer_S4_Rec
          annotation (Placement(transformation(extent={{210,84},{316,142}})));
        Modelica.Blocks.Sources.BooleanStep startShortCircuit(startTime=
              consumer_S4_Rec.scTime)
          annotation (Placement(transformation(extent={{-178,52},{-158,72}})));
        Modelica.Blocks.Continuous.Derivative derivative
          annotation (Placement(transformation(extent={{14,52},{34,72}})));
        Resistance_ShortCircuit resistance_ShortCircuit_TL
          annotation (Placement(transformation(extent={{-38,44},{-4,80}})));
        Modelica.Electrical.Analog.Basic.Resistor resistorL(R=consumer_S4_Rec.R_L)
          annotation (Placement(transformation(extent={{-250,-8},{-230,12}})));
        Modelica.Electrical.Analog.Basic.Inductor inductorL(L=consumer_S4_Rec.L)
          annotation (Placement(transformation(extent={{-284,-8},{-264,12}})));
        Modelica.Electrical.Analog.Basic.Capacitor capacitorC(C=consumer_S4_Rec.C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-210,-20})));
        Modelica.Electrical.Analog.Basic.Resistor resistorRC(R=consumer_S4_Rec.R_C2)
          annotation (Placement(transformation(
              extent={{-10,-10},{10,10}},
              rotation=270,
              origin={-210,-52})));
      equation
        connect(consumerResistor.n,n)  annotation (Line(points={{12,2},{340,2}},               color={0,0,255}));
        connect(resistance_ShortCircuit_TL.Rds, derivative.u)
          annotation (Line(points={{-2.98,62},{12,62}}, color={0,0,127}));
        connect(resistance_ShortCircuit_TL.shortCircuitTrigger,
          startShortCircuit.y) annotation (Line(points={{-37.32,62.36},{-40,62},
                {-157,62}}, color={255,0,255}));
        connect(consumerResistor.R, resistance_ShortCircuit_TL.Rds)
          annotation (Line(points={{0,16.4},{0,62},{-2.98,62}}, color={0,0,127}));
        connect(resistorRC.p, capacitorC.n)
          annotation (Line(points={{-210,-42},{-210,-30}}, color={0,0,255}));
        connect(resistorL.p, inductorL.n)
          annotation (Line(points={{-250,2},{-264,2}}, color={0,0,255}));
        connect(inductorL.p, p) annotation (Line(points={{-284,2},{-324,2},{-324,30},
                {-344,30}}, color={0,0,255}));
        connect(resistorRC.n, n) annotation (Line(points={{-210,-62},{-210,-78},{
                330,-78},{330,2},{340,2}}, color={0,0,255}));
        connect(resistorL.n, consumerResistor.p)
          annotation (Line(points={{-230,2},{-12,2}}, color={0,0,255}));
        connect(capacitorC.p, consumerResistor.p)
          annotation (Line(points={{-210,-10},{-210,2},{-12,2}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-340,-100},
                  {340,180}}), graphics={
              Rectangle(
                extent={{-340,180},{340,136}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor={236,236,236},
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-340,130},{340,-102}},
                lineColor={28,108,200},
                lineThickness=1,
                pattern=LinePattern.Dash,
                fillColor=DynamicSelect({255,255,255}, if enableShortFunctionality then {255,200,175} else {255,255,255}),
                fillPattern=FillPattern.Solid),
              Rectangle(
                extent={{-330,122},{330,-86}},
                lineColor={28,108,200},
                lineThickness=0.5,
                pattern=LinePattern.Dash),
              Rectangle(
                extent={{68,52},{110,10}},
                fillColor={0,127,0},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={0,0,0}),
              Rectangle(
                extent={{110,52},{152,10}},
                fillColor={0,0,255},
                fillPattern=FillPattern.Solid,
                lineThickness=0.5,
                pattern=LinePattern.None),
              Line(points={{30,30},{348,30}},color={0,0,0}),
              Line(points={{-346,30},{-140,30}},
                                               color={0,0,0}),
              Text(
                extent={{-284,178},{318,154}},
                lineColor={28,108,200},
                horizontalAlignment=TextAlignment.Left,
                textString=consumerData.fullNameOfConsumer,
                textStyle={TextStyle.Bold}),
              Text(
                extent={{-280,128},{218,52}},
                textColor={28,108,200},
                textString=String(consumerData.consumerClass)),
              Rectangle(
                extent={{-52,6},{-30,-34}},
                lineColor={28,108,200},
                lineThickness=1),
              Rectangle(
                extent={{-11,20},{11,-20}},
                lineColor={28,108,200},
                lineThickness=1,
                origin={-93,30},
                rotation=90),
              Line(
                points={{-54,-52},{-30,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-54,-58},{-30,-58}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-42,-34},{-42,-52}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-42,-58},{-42,-70}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-74,30},{68,30}},
                color={28,108,200},
                thickness=1),
              Line(
                points={{-42,6},{-42,30}},
                color={28,108,200},
                thickness=1),
              Rectangle(
                extent={{-11,20},{11,-20}},
                lineColor={28,108,200},
                lineThickness=1,
                origin={-159,30},
                rotation=90,
                fillColor={28,108,200},
                fillPattern=FillPattern.Solid),
              Line(
                points={{-138,30},{-114,30}},
                color={28,108,200},
                thickness=1)}), Diagram(coordinateSystem(preserveAspectRatio=false,
                extent={{-340,-100},{340,180}}), graphics={
              Text(
                extent={{40,72},{106,56}},
                textColor={255,255,255},
                textString="Current"),
              Rectangle(
                extent={{-48,98},{40,30}},
                fillColor={170,255,213},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Rectangle(
                extent={{-314,18},{-90,-80}},
                lineColor={0,0,0},
                pattern=LinePattern.Dot,
                lineThickness=0.5),
              Text(
                extent={{-162,-50},{-98,-70}},
                textColor={0,0,0},
                textString="Input Circuit"),
              Rectangle(
                extent={{-186,88},{-116,44}},
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None,
                lineColor={102,44,145}),
              Text(
                extent={{-162,92},{-112,76}},
                textColor={0,140,72},
                fontSize=6,
                textString="Short Circuit")}));
      end Consumer_S4_Left_T_Input;

      model Resistance_ShortCircuit

        // In- Outputs
        Modelica.Blocks.Interfaces.RealOutput Rds
          annotation (Placement(transformation(extent={{96,-10},{116,10}}),
              iconTransformation(extent={{96,-10},{116,10}})));
        Modelica.Blocks.Interfaces.BooleanInput shortCircuitTrigger annotation (
            Placement(transformation(
              extent={{-20,-20},{20,20}},
              rotation=0,
              origin={-96,2}),   iconTransformation(
              extent={{-20,-20},{20,20}},
              rotation=0,
              origin={-96,2})));

        parameter Real A = 1.9999e20 "Coefficient A of: A*t^3 + B*t^2 + C*t + D";
        parameter Real B = -2.99985e+14 "Coefficient B of: A*t^3 + B*t^2 + C*t + D";
        parameter Real C = 0 "Coefficient C of: A*t^3 + B*t^2 + C*t + D";
        parameter Real D = 100 "Coefficient D of: A*t^3 + B*t^2 + C*t + D";

        Real t "Evaluation variable of the third order polynomnial";
        Real startOfSwitchingTime;
        Real dt = -duration "Helper variable: t1 - t2 = 0 - duration";

        parameter Real du = 0;
        parameter Real u = 100 "Default resistance for consumers";
        parameter Modelica.Units.SI.Time duration = 1e-6 "How long does it take to reach the const value?";
        parameter Modelica.Units.SI.Resistance constValue=5e-3 "Final resistance value after short circuit";

        parameter Real activation_factor = 1.0 "Factor is multiplied with consumer resistance";

      equation

        when shortCircuitTrigger then
          startOfSwitchingTime = time;
        end when;

        t = time - startOfSwitchingTime;

        if shortCircuitTrigger then
           if t <= duration then
             Rds = A*t^3 + B*t^2 + C*t + D;
           else
             Rds = constValue;
           end if;
        else
            Rds * activation_factor = u;
        end if;
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
                                 Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={28,108,200},
                lineThickness=1,
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),                                 Text(
                extent={{-78,62},{76,-66}},
                textColor={28,108,200},
                textString="f")}), Diagram(coordinateSystem(preserveAspectRatio=false)));
      end Resistance_ShortCircuit;
    end Consumer;

    package Fuse
      model NonlinearDiode

        extends Modelica.Electrical.Analog.Interfaces.OnePort;

        parameter Modelica.Units.SI.Voltage Vt=0.04 "Voltage equivalent of temperature (kT/qn)";
        parameter Modelica.Units.SI.Resistance R=1e8 "Parallel ohmic resistance";
        parameter Modelica.Units.SI.Voltage Bv=0.6 "Breakdown voltage";
        parameter Modelica.Units.SI.Current Ibv=0.7 "Breakdown knee current";
        parameter Real Nbv=0.74 "Breakdown emission coefficient";

      equation
         i = Ibv*exp( (v-Bv)/(Nbv*Vt)) + v/R;

        annotation (Icon(graphics={
              Polygon(
                points={{28,0},{-32,40},{-32,-40},{28,0}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Line(points={{28,40},{28,-40}},   color={0,0,255}),
                Line(points={{-104,0},{-32,0}},
                                              color={0,0,255}),
                Line(points={{28,0},{98,0}},  color={0,0,255})}));
      end NonlinearDiode;

      model Fuse1

        Modelica.Electrical.Analog.Basic.VariableResistor resistor(alpha=0,
            useHeatPort=false)
          annotation (Placement(transformation(extent={{-16,-14},{12,14}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin
                    p "Positive electrical pin"
          annotation (Placement(transformation(extent={{-114,-10},{-94,10}}),
              iconTransformation(extent={{-114,-10},{-94,10}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin
                    n "Negative electrical pin"
          annotation (Placement(transformation(extent={{72,-10},{92,10}}),
              iconTransformation(extent={{72,-10},{92,10}})));
        Resistance_Fuse resistance_Fuse_TL(u_high=100000)
          annotation (Placement(transformation(extent={{-30,42},{-10,62}})));
         Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor_iSens
          annotation (Placement(transformation(extent={{-68,-10},{-48,10}})));
        Modelica.Blocks.Continuous.FirstOrder
                                     firstOrder(T=1e-7, initType=Modelica.Blocks.Types.Init.InitialState)
                    annotation (Placement(
              transformation(
              extent={{4,-4},{-4,4}},
              rotation=0,
              origin={-116,42})));
        Modelica.Blocks.Logical.Greater overcurrentFault_trigger
          annotation (Placement(transformation(extent={{-84,76},{-64,96}})));
        Modelica.Blocks.Sources.RealExpression limit(y=120)
          annotation (Placement(transformation(extent={{-132,54},{-90,74}})));
        Fuse.NonlinearDiode nonlinearDiode(Bv=32) annotation (Placement(
              transformation(
              extent={{-10,-10},{10,10}},
              rotation=0,
              origin={0,-22})));
      equation

        connect(resistor.n,n)
          annotation (Line(points={{12,0},{82,0}},  color={0,0,255}));
        connect(currentSensor_iSens.i,firstOrder. u) annotation (Line(points={{-58,-11},
                {-58,-16},{-90,-16},{-90,42},{-111.2,42}},   color={162,29,33}));
        connect(overcurrentFault_trigger.u1,firstOrder. y) annotation (Line(points={{-86,86},
                {-140,86},{-140,42},{-120.4,42}},     color={162,29,33}));
        connect(limit.y, overcurrentFault_trigger.u2) annotation (Line(points={
                {-87.9,64},{-86,64},{-86,78}}, color={0,0,127}));
        connect(p, currentSensor_iSens.p)
          annotation (Line(points={{-104,0},{-68,0}}, color={0,0,255}));
        connect(currentSensor_iSens.n,resistor. p)
          annotation (Line(points={{-48,0},{-16,0}}, color={0,0,255}));
        connect(resistance_Fuse_TL.Rds,resistor. R)
          annotation (Line(points={{-9.4,52},{-2,52},{-2,16.8}}, color={0,0,127}));
        connect(overcurrentFault_trigger.y, resistance_Fuse_TL.switch_signal)
          annotation (Line(points={{-63,86},{-42,86},{-42,52},{-30.6,52}}, color={
                255,0,255}));
        connect(nonlinearDiode.p,resistor. p) annotation (Line(points={{-10,-22},{
                -22,-22},{-22,0},{-16,0}}, color={0,0,255}));
        connect(nonlinearDiode.n, n) annotation (Line(points={{10,-22},{24,-22},{24,
                0},{82,0}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-200,
                  -120},{200,140}}), graphics={
              Rectangle(
                extent={{-80,30},{60,-30}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Line(points={{-100,0},{-80,0}},color={0,0,255}),
              Line(points={{60,0},{80,0}}, color={0,0,255}),
              Line(
                visible=useHeatPort,
                points={{-10,-100},{-10,-30}},
                color={127,0,0},
                pattern=LinePattern.Dot),
              Line(points={{-50,30},{-50,-30}}, color={28,108,200}),
              Line(points={{30,30},{30,-30}}, color={28,108,200})}),
                                Diagram(coordinateSystem(preserveAspectRatio=false,
                extent={{-200,-120},{200,140}}), graphics={
              Rectangle(
                extent={{-142,108},{-38,50}},
                lineColor={28,108,200},
                lineThickness=0.5,
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None),
              Text(
                extent={{-140,112},{-92,88}},
                textColor={28,108,200},
                fontSize=8,
                horizontalAlignment=TextAlignment.Left,
                textString="Overcurrent Fault
Detection")}));
      end Fuse1;

      model Fuse2
        Modelica.Electrical.Analog.Basic.VariableResistor resistor(alpha=0,
            useHeatPort=false)
          annotation (Placement(transformation(extent={{-14,-14},{14,14}})));
        Resistance_Fuse resistance_Fuse_TL(u_high=100000)
          annotation (Placement(transformation(extent={{-28,42},{-8,62}})));
         Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor_iSens
          annotation (Placement(transformation(extent={{-66,-10},{-46,10}})));
        Modelica.Blocks.Continuous.FirstOrder
                                     firstOrder(T=1e-7, initType=Modelica.Blocks.Types.Init.InitialState)
                    annotation (Placement(
              transformation(
              extent={{4,-4},{-4,4}},
              rotation=0,
              origin={-114,42})));
        Modelica.Blocks.Logical.Greater overcurrentFault_trigger
          annotation (Placement(transformation(extent={{-82,76},{-62,96}})));
        Modelica.Blocks.Sources.RealExpression limit(y=120)
          annotation (Placement(transformation(extent={{-130,54},{-88,74}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin
                    p "Positive electrical pin"
          annotation (Placement(transformation(extent={{-110,-10},{-90,10}}),
              iconTransformation(extent={{-110,-10},{-90,10}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin
                    n "Negative electrical pin"
          annotation (Placement(transformation(extent={{90,-10},{110,10}}),
              iconTransformation(extent={{90,-10},{110,10}})));
      equation
        connect(resistor.n,n)
          annotation (Line(points={{14,0},{100,0}}, color={0,0,255}));
        connect(currentSensor_iSens.i,firstOrder. u) annotation (Line(points={{-56,-11},
                {-56,-16},{-88,-16},{-88,42},{-109.2,42}},   color={162,29,33}));
        connect(overcurrentFault_trigger.u1,firstOrder. y) annotation (Line(points={{-84,86},
                {-138,86},{-138,42},{-118.4,42}},     color={162,29,33}));
        connect(limit.y, overcurrentFault_trigger.u2) annotation (Line(points={
                {-85.9,64},{-84,64},{-84,78}}, color={0,0,127}));
        connect(p,currentSensor_iSens. p)
          annotation (Line(points={{-100,0},{-66,0}}, color={0,0,255}));
        connect(currentSensor_iSens.n,resistor. p)
          annotation (Line(points={{-46,0},{-14,0}}, color={0,0,255}));
        connect(resistance_Fuse_TL.Rds,resistor. R)
          annotation (Line(points={{-7.4,52},{0,52},{0,16.8}},   color={0,0,127}));
        connect(overcurrentFault_trigger.y,resistance_Fuse_TL. switch_signal)
          annotation (Line(points={{-61,86},{-40,86},{-40,52},{-28.6,52}}, color={
                255,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{-140,
                  -120},{140,120}}), graphics={
              Rectangle(
                extent={{-70,30},{70,-30}},
                lineColor={0,0,255},
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),
              Line(points={{-90,0},{-70,0}}, color={0,0,255}),
              Line(points={{70,0},{90,0}}, color={0,0,255}),
              Line(
                visible=useHeatPort,
                points={{0,-100},{0,-30}},
                color={127,0,0},
                pattern=LinePattern.Dot),
              Line(points={{-40,30},{-40,-30}}, color={28,108,200}),
              Line(points={{40,30},{40,-30}}, color={28,108,200})}),
                                      Diagram(coordinateSystem(preserveAspectRatio=
                  false, extent={{-140,-120},{140,120}}), graphics={
              Rectangle(
                extent={{-140,108},{-36,50}},
                lineColor={28,108,200},
                lineThickness=0.5,
                fillColor={170,255,170},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.None),
              Text(
                extent={{-138,112},{-90,88}},
                textColor={28,108,200},
                fontSize=8,
                horizontalAlignment=TextAlignment.Left,
                textString="Overcurrent Fault
Detection")}));
      end Fuse2;

      model Resistance_Fuse

        Modelica.Blocks.Interfaces.RealOutput Rds;
        Modelica.Blocks.Interfaces.BooleanInput switch_signal;

        parameter Modelica.Units.SI.Resistance u_low  = 1e-3;
        parameter Modelica.Units.SI.Resistance u_high = 1.0;
        parameter Modelica.Units.SI.Time T_switch = 1e-3;

        discrete Modelica.Units.SI.Time t1(start=0);
        discrete Boolean triggered(start=false);

      equation

        when switch_signal then
          t1 = time;
          triggered = true;
        end when;

        Rds =
          if not triggered then
            u_low
          elseif time < t1 + T_switch then
            u_low + (u_high - u_low)*
            (3*((time - t1)/T_switch)^2 - 2*((time - t1)/T_switch)^3)
          else
            u_high;
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={Text(
                extent={{-94,114},{88,-54}},
                textColor={28,108,200},
                textString="f"), Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={28,108,200},
                lineThickness=1,
                fillColor={255,255,255},
                fillPattern=FillPattern.Solid),                                 Text(
                extent={{-92,80},{90,-88}},
                textColor={28,108,200},
                textString="f")}),                                     Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end Resistance_Fuse;
    end Fuse;

    package Harness
      model Cable
        Modelica.Electrical.Analog.Interfaces.PositivePin
                    p "Positive electrical pin"
          annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin
                    n "Negative electrical pin"
          annotation (Placement(transformation(extent={{90,-10},{110,10}})));
        Modelica.Thermal.HeatTransfer.Celsius.FixedTemperature fixedTemperature(T=
              harnessConfig.ambientTemperature) annotation (Placement(
              transformation(
              extent={{-12,-11.5},{12,11.5}},
              rotation=90,
              origin={-19.5,-40})));
        Modelica.Electrical.Analog.Basic.Resistor contactResistance_p(R=
              harnessConfig.contactResistance_p)
          annotation (Placement(transformation(extent={{-74,-10},{-54,10}})));
        Modelica.Electrical.Analog.Basic.Resistor contactResistance_n(R=
              harnessConfig.contactResistance_n)
          annotation (Placement(transformation(extent={{14,-10},{34,10}})));
        Modelica.Electrical.Analog.Basic.Resistor cableResistor(R=harnessConfig.cableResistance,
                                                                useHeatPort=true)
          annotation (Placement(transformation(extent={{-38,-18},{-2,18}})));
        Harness_Rec harnessConfig
          annotation (Placement(transformation(extent={{76,-56},{96,-36}})));
        Modelica.Electrical.Analog.Basic.Inductor inductor1(L=harnessConfig.L)
          annotation (Placement(transformation(extent={{56,-10},{76,10}})));
      equation
        connect(contactResistance_p.p, p)
          annotation (Line(points={{-74,0},{-100,0}},color={0,0,255}));
        connect(cableResistor.heatPort, fixedTemperature.port) annotation (Line(
              points={{-20,-18},{-19.5,-18},{-19.5,-28}}, color={191,0,0}));
        connect(cableResistor.p, contactResistance_p.n)
          annotation (Line(points={{-38,0},{-54,0}}, color={0,0,255}));
        connect(cableResistor.n, contactResistance_n.p)
          annotation (Line(points={{-2,0},{14,0}}, color={0,0,255}));
        connect(contactResistance_n.n, inductor1.p)
          annotation (Line(points={{34,0},{56,0}}, color={0,0,255}));
        connect(inductor1.n, n)
          annotation (Line(points={{76,0},{100,0}}, color={0,0,255}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{
                  -100,-60},{100,60}}), graphics={
              Rectangle(
                extent={{-80,14},{-10,-12}},
                fillColor={244,125,35},
                fillPattern=FillPattern.Solid,
                pattern=LinePattern.Dash,
                lineThickness=0.5,
                lineColor={135,135,135}),
              Rectangle(
                extent={{6,14},{80,-12}},
                lineColor={0,0,0},
                lineThickness=1),
              Line(
                points={{-90,0},{-80,0}},
                color={0,0,0},
                thickness=1),
              Line(
                points={{-10,0},{6,0}},
                color={0,0,0},
                thickness=1),
              Line(
                points={{90,0},{80,0}},
                color={0,0,0},
                thickness=1)}),                                        Diagram(
              coordinateSystem(preserveAspectRatio=false, extent={{-100,-60},{100,
                  60}})));
      end Cable;

      model Harness_Rec
          extends Modelica.Icons.Record;

          // Harness config

          parameter Modelica.Units.NonSI.Temperature_degC ambientTemperature=20 "Global reference temperature [°C]" annotation (Dialog(group="Electrical properties", enable=D_DS_en));
          parameter Modelica.Units.SI.Resistance contactResistance_p=1e-4 "Contact resistance before cable resistor [Ohm]" annotation (Dialog(group="Electrical properties", enable=D_DS_en));
          parameter Modelica.Units.SI.Resistance contactResistance_n=1e-4 "Contact resistance after cable resistor [Ohm]" annotation (Dialog(group="Electrical properties", enable=D_DS_en));
          parameter Modelica.Units.SI.Resistance cableResistance=1e-3 "Cable resistance [Ohm]" annotation (Dialog(group="Electrical properties", enable=D_DS_en));
          parameter Modelica.Units.SI.Inductance L=1e-6 "Cable inductance [H]" annotation (Dialog(group="Electrical properties", enable=D_DS_en));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
              coordinateSystem(preserveAspectRatio=false)));
      end Harness_Rec;

      model GroundBolt
        Modelica.Thermal.HeatTransfer.Celsius.FixedTemperature fixedTemperature(T=20)                  annotation (Placement(transformation(extent={{-13.5,-13.5},{13.5,13.5}},
              rotation=90,
              origin={0.5,-51.5})));
        Modelica.Electrical.Analog.Basic.Resistor contactResistor(
          R=7e-4,
          alpha=5.7e-3,
          useHeatPort=true)                                                                              annotation (Placement(transformation(extent={{-10,-10},
                  {10,10}})));
        Modelica.Electrical.Analog.Interfaces.PositivePin
                    p "Positive electrical pin"
          annotation (Placement(transformation(extent={{-110,-10},{-90,10}})));
        Modelica.Electrical.Analog.Interfaces.NegativePin
                    n "Negative electrical pin"
          annotation (Placement(transformation(extent={{90,-10},{110,10}})));
      equation
        connect(p,contactResistor. p) annotation (Line(points={{-100,0},{-10,0}}, color={0,0,255}));
        connect(contactResistor.n,n)  annotation (Line(points={{10,0},{100,0}}, color={0,0,255}));
        connect(fixedTemperature.port,contactResistor. heatPort) annotation (Line(points={{0.5,-38},
                {0,-38},{0,-10}},                                                                                     color={191,0,0}));
        annotation (Icon(coordinateSystem(preserveAspectRatio=false), graphics={
              Rectangle(
                extent={{-54,22},{54,-20}},
                pattern=LinePattern.None,
                fillColor={0,0,0},
                fillPattern=FillPattern.Solid,
                lineColor={255,255,255}),
              Line(
                points={{-18,-2},{18,-2}},
                color={255,255,255},
                thickness=1),
              Line(
                points={{-13,-6},{14,-6}},
                color={255,255,255},
                thickness=1),
              Line(
                points={{-10,-10},{10,-10}},
                color={255,255,255},
                thickness=1),
              Line(
                points={{0,14},{0,-2}},
                color={255,255,255},
                thickness=1),
              Ellipse(
                extent={{-20,20},{20,-18}},
                lineColor={255,255,255},
                lineThickness=1,
                startAngle=0,
                endAngle=360),
              Line(
                points={{-92,0},{-54,0}},
                color={0,0,0},
                thickness=1),
              Line(
                points={{54,0},{92,0}},
                color={0,0,0},
                thickness=1)}), Diagram(coordinateSystem(preserveAspectRatio=
                  false)));
      end GroundBolt;
    end Harness;
  end Components;

  package Models
    model scConsumer_Translator
      Modelica.Electrical.Analog.Sources.ConstantVoltage G1_BATTERIE(V=12)
        annotation (Placement(transformation(extent={{-352,124},{-332,144}})));
      Components.Harness.Cable cable(harnessConfig(cableResistance=1.75e-4, L=
              1.544e-7))
        annotation (Placement(transformation(extent={{-378,-56},{-344,-36}})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_1
        annotation (Placement(transformation(extent={{-284,-64},{-230,-26}})));

      Components.Consumer.dummyLoad dummyLoad annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-274,-74})));
      Components.Harness.Cable cable1(harnessConfig(cableResistance=0.001194, L
            =0.650e-6))
        annotation (Placement(transformation(extent={{-230,-56},{-196,-36}})));
      Components.Harness.Cable cable2(harnessConfig(cableResistance=0.001258, L
            =0.6853e-6))
        annotation (Placement(transformation(extent={{-106,-56},{-72,-36}})));
      Components.Harness.Cable cable3(harnessConfig(cableResistance=0.0002, L=
              1.845e-7))
        annotation (Placement(transformation(extent={{-354,212},{-320,232}})));
      Components.Harness.Cable cable4(harnessConfig(cableResistance=0.020, L=
              1.8075e-6))
        annotation (Placement(transformation(extent={{-32,176},{2,196}})));
      Components.Harness.Cable cable5(harnessConfig(cableResistance=0.02144, L=
              1.87222e-6))
        annotation (Placement(transformation(extent={{92,176},{126,196}})));
      Components.Harness.Cable cable6(harnessConfig(cableResistance=0.0111, L=
              2.0e-6))
        annotation (Placement(transformation(extent={{-32,140},{2,160}})));
      Components.Harness.Cable cable7(harnessConfig(cableResistance=0.0047, L=
              0.85e-6))
        annotation (Placement(transformation(extent={{92,140},{126,160}})));
      Components.Harness.Cable cable8(harnessConfig(cableResistance=0.0026, L=
              1.04667e-6))
        annotation (Placement(transformation(extent={{-32,104},{2,124}})));
      Components.Harness.Cable cable9(harnessConfig(cableResistance=0.0003437,
            L=0.134032e-6))
        annotation (Placement(transformation(extent={{92,104},{126,124}})));
      Components.Harness.Cable cable14(harnessConfig(cableResistance=0.0179, L=
              1.56e-6))
        annotation (Placement(transformation(extent={{-32,212},{2,232}})));
      Components.Harness.Cable cable15(harnessConfig(cableResistance=0.01915, L
            =1.5e-6))
        annotation (Placement(transformation(extent={{92,212},{126,232}})));
      Components.Consumer.dummyLoad dummyLoad1 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-118,206})));
      Components.Consumer.dummyLoad dummyLoad2 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-118,170})));
      Components.Harness.GroundBolt groundBolt1
        annotation (Placement(transformation(extent={{178,210},{200,234}})));
      Components.Harness.Cable cable10(harnessConfig(L=0.37e-6)) annotation (
          Placement(transformation(
            extent={{-16,-11},{16,11}},
            rotation=90,
            origin={171,144})));
      Components.Harness.GroundBolt groundBolt3
        annotation (Placement(transformation(extent={{178,246},{200,270}})));
      Components.Harness.GroundBolt groundBolt2
        annotation (Placement(transformation(extent={{178,174},{200,198}})));
      Components.Harness.GroundBolt groundBolt4
        annotation (Placement(transformation(extent={{-282,122},{-260,146}})));
      Components.Harness.Cable cable11(harnessConfig(cableResistance=5.162e-5,
            L=4.55e-8))
        annotation (Placement(transformation(extent={{-324,124},{-290,144}})));
      Components.Harness.Cable cable22(harnessConfig(cableResistance=0.1386, L=
              2.231e-6))
        annotation (Placement(transformation(extent={{-46,-242},{-12,-222}})));
      Components.Harness.Cable cable23(harnessConfig(cableResistance=0.09896, L
            =1.59288e-6))
        annotation (Placement(transformation(extent={{78,-242},{112,-222}})));
      Components.Harness.Cable cable24(harnessConfig(cableResistance=0.0136, L=
              1.1891e-6))
        annotation (Placement(transformation(extent={{-46,-278},{-12,-258}})));
      Components.Harness.Cable cable25(harnessConfig(cableResistance=0.0049, L=
              0.42951e-6))
        annotation (Placement(transformation(extent={{78,-278},{112,-258}})));
      Components.Harness.Cable cable26(harnessConfig(cableResistance=0.0084, L=
              0.73533e-6))
        annotation (Placement(transformation(extent={{-46,-314},{-12,-294}})));
      Components.Harness.Cable cable27(harnessConfig(cableResistance=0.0113, L=
              0.9889e-6))
        annotation (Placement(transformation(extent={{78,-314},{112,-294}})));
      Components.Harness.Cable cable28(harnessConfig(cableResistance=0.025, L=
              2.269e-6))
        annotation (Placement(transformation(extent={{-46,-206},{-12,-186}})));
      Components.Harness.Cable cable29(harnessConfig(cableResistance=0.0076, L=
              0.6669e-6))
        annotation (Placement(transformation(extent={{78,-206},{112,-186}})));
      Components.Harness.Cable cable30(harnessConfig(cableResistance=0.1493, L=
              4.66958e-6))
        annotation (Placement(transformation(extent={{-46,-386},{-12,-366}})));
      Components.Harness.Cable cable31(harnessConfig(cableResistance=0.044, L=
              1.3761e-6))
        annotation (Placement(transformation(extent={{78,-386},{112,-366}})));
      Components.Harness.Cable cable32(harnessConfig(L=2.7152e-6))
        annotation (Placement(transformation(extent={{-46,-422},{-12,-402}})));
      Components.Harness.Cable cable33(harnessConfig(cableResistance=0.047, L=
              1.1343e-6))
        annotation (Placement(transformation(extent={{78,-422},{112,-402}})));
      Components.Harness.Cable cable36(harnessConfig(cableResistance=0.02044, L
            =1.7845e-6))
        annotation (Placement(transformation(extent={{-46,-350},{-12,-330}})));
      Components.Harness.Cable cable37(harnessConfig(cableResistance=0.00352, L
            =0.3076e-6))
        annotation (Placement(transformation(extent={{78,-350},{112,-330}})));
      Components.Consumer.dummyLoad dummyLoad3 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-128,-250})));
      Components.Consumer.dummyLoad dummyLoad4 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-128,-284})));
      Components.Consumer.dummyLoad dummyLoad6 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-128,-356})));
      Components.Fuse.Fuse2 eFuse_S2_2 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={-212,-232})));
      Components.Fuse.Fuse2 eFuse_S2_3 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={-212,-340})));
      Components.Fuse.Fuse2 eFuse_S2_4 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={-212,-268})));
      Components.Fuse.Fuse2 eFuse_S2_5 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={-212,-412})));
      Components.Consumer.dummyLoad dummyLoad5 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={-128,-430})));
      Components.Harness.GroundBolt groundBolt5
        annotation (Placement(transformation(extent={{186,-172},{208,-148}})));
      Components.Harness.GroundBolt groundBolt6
        annotation (Placement(transformation(extent={{150,-208},{172,-184}})));
      Components.Harness.GroundBolt groundBolt7
        annotation (Placement(transformation(extent={{150,-244},{172,-220}})));
      Components.Harness.GroundBolt groundBolt8
        annotation (Placement(transformation(extent={{150,-280},{172,-256}})));
      Components.Harness.GroundBolt groundBolt9
        annotation (Placement(transformation(extent={{150,-352},{172,-328}})));
      Components.Harness.GroundBolt groundBolt10
        annotation (Placement(transformation(extent={{150,-388},{172,-364}})));
      Modelica.Electrical.Analog.Basic.Ground ground
        annotation (Placement(transformation(extent={{-272,62},{-224,110}})));
      Components.Harness.Cable cable34(harnessConfig(cableResistance=0.00253, L
            =0.2212e-6))
        annotation (Placement(transformation(extent={{144,-170},{178,-150}})));
      Modelica.Electrical.Analog.Sources.ConstantVoltage battery(V=12.5)
        annotation (Placement(transformation(extent={{-346,-226},{-326,-206}})));
      Components.Harness.GroundBolt groundBolt11
        annotation (Placement(transformation(extent={{-52,-58},{-30,-34}})));
      Components.Consumer.dummyLoad dummyLoad7 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={470,258})));
      Components.Harness.Cable cable35(harnessConfig(cableResistance=0.1017, L=
              1.637e-6))
        annotation (Placement(transformation(extent={{468,-226},{502,-206}})));
      Components.Harness.Cable cable39(harnessConfig(cableResistance=0.0906, L=
              1.4586e-6))
        annotation (Placement(transformation(extent={{592,-262},{626,-242}})));
      Components.Harness.Cable cable40(harnessConfig(cableResistance=0.144, L=
              2.31811e-6))
        annotation (Placement(transformation(extent={{468,-262},{502,-242}})));
      Components.Harness.Cable cable41(harnessConfig(cableResistance=0.1320, L=
              2.1257e-6))
        annotation (Placement(transformation(extent={{592,-298},{626,-278}})));
      Components.Harness.Cable cable42(harnessConfig(cableResistance=0.1628, L=
              2.6217e-6))
        annotation (Placement(transformation(extent={{468,-298},{502,-278}})));
      Components.Harness.Cable cable43(harnessConfig(cableResistance=0.0021, L=
              0.1864e-6))
        annotation (Placement(transformation(extent={{592,-334},{626,-314}})));
      Components.Harness.Cable cable44(harnessConfig(cableResistance=199e-3, L=
              3.076e-6))
        annotation (Placement(transformation(extent={{468,-190},{502,-170}})));
      Components.Harness.Cable cable45(harnessConfig(cableResistance=0.1017, L=
              1.637e-6))
        annotation (Placement(transformation(extent={{592,-226},{626,-206}})));
      Components.Harness.Cable cable46(harnessConfig(cableResistance=0.0111, L=
              0.969e-6))
        annotation (Placement(transformation(extent={{468,-334},{502,-314}})));
      Components.Harness.Cable cable47(harnessConfig(cableResistance=0.03039, L
            =1.723e-6))
        annotation (Placement(transformation(extent={{592,-370},{626,-350}})));
      Components.Harness.Cable cable48(harnessConfig(cableResistance=0.0751, L=
              2.3507e-6))
        annotation (Placement(transformation(extent={{468,-370},{502,-350}})));
      Components.Harness.Cable cable49(harnessConfig(cableResistance=0.0342, L=
              1.07034e-6))
        annotation (Placement(transformation(extent={{592,-406},{626,-386}})));
      Components.Consumer.dummyLoad dummyLoad8 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-232})));
      Components.Consumer.dummyLoad dummyLoad9 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-270})));
      Components.Consumer.dummyLoad dummyLoad10 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-306})));
      Components.Consumer.dummyLoad dummyLoad11 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-342})));
      Components.Consumer.dummyLoad dummyLoad12 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-378})));
      Components.Consumer.dummyLoad dummyLoad13 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={394,-410})));
      Components.Harness.Cable cable50(harnessConfig(cableResistance=0.1396, L=
              4.3689e-6))
        annotation (Placement(transformation(extent={{284,-408},{318,-388}})));
      Components.Harness.Cable cable51(harnessConfig(cableResistance=0.003, L=
              0.5404e-6))
        annotation (Placement(transformation(extent={{296,-266},{330,-246}})));
      Components.Harness.Cable cable52(harnessConfig(cableResistance=0.003, L=
              0.5377e-6))
        annotation (Placement(transformation(extent={{296,-340},{330,-320}})));
      Components.Harness.Cable cable53(harnessConfig(cableResistance=0.003, L=
              0.538e-6))
        annotation (Placement(transformation(extent={{296,-298},{330,-278}})));
      Components.Harness.Cable cable54(harnessConfig(cableResistance=0.003, L=
              0.5446e-6))
        annotation (Placement(transformation(extent={{296,-228},{330,-208}})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_23 annotation (Placement(
            transformation(
            extent={{-27,-19},{27,19}},
            rotation=180,
            origin={495,179})));

      Components.Fuse.Fuse2 conventionalFuse_Stage3_24 annotation (Placement(
            transformation(
            extent={{-27,-19},{27,19}},
            rotation=180,
            origin={495,137})));

      Components.Fuse.Fuse2 conventionalFuse_Stage3_25 annotation (Placement(
            transformation(
            extent={{-27,-19},{27,19}},
            rotation=180,
            origin={495,99})));

      Components.Fuse.Fuse2 conventionalFuse_Stage3_26 annotation (Placement(
            transformation(
            extent={{-27,-19},{27,19}},
            rotation=180,
            origin={495,59})));

      Components.Harness.GroundBolt groundBolt12
        annotation (Placement(transformation(extent={{680,-192},{702,-168}})));
      Components.Harness.GroundBolt groundBolt13
        annotation (Placement(transformation(extent={{680,-228},{702,-204}})));
      Components.Harness.GroundBolt groundBolt14
        annotation (Placement(transformation(extent={{680,-300},{702,-276}})));
      Components.Harness.GroundBolt groundBolt15
        annotation (Placement(transformation(extent={{680,-336},{702,-312}})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_27
        annotation (Placement(transformation(extent={{976,-46},{1030,-8}})));
      Components.Harness.Cable cable55(harnessConfig(cableResistance=0.01948, L
            =1.71e-6))
        annotation (Placement(transformation(extent={{1030,-38},{1064,-18}})));
      Components.Harness.Cable cable56(harnessConfig(cableResistance=0.0111, L=
              0.98e-6))
        annotation (Placement(transformation(extent={{1154,-38},{1188,-18}})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_28
        annotation (Placement(transformation(extent={{974,-226},{1028,-188}})));

      Components.Harness.Cable cable57(harnessConfig(cableResistance=0.0194, L=
              0.676e-6)) annotation (Placement(transformation(extent={{1028,-218},
                {1062,-198}})));
      Components.Harness.Cable cable58(harnessConfig(cableResistance=0.0111, L=
              0.2736e-6)) annotation (Placement(transformation(extent={{1152,-218},
                {1186,-198}})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_29
        annotation (Placement(transformation(extent={{974,-402},{1028,-364}})));
      Components.Harness.Cable cable59(harnessConfig(cableResistance=0.0025, L=
              0.6768e-6)) annotation (Placement(transformation(extent={{1028,-394},
                {1062,-374}})));
      Components.Harness.Cable cable60(harnessConfig(cableResistance=0.001, L=
              0.2736e-6)) annotation (Placement(transformation(extent={{1152,-394},
                {1186,-374}})));
      Components.Harness.Cable cable61(harnessConfig(cableResistance=0.0003, L=
              0.2113e-6)) annotation (Placement(transformation(
            extent={{-17,-10},{17,10}},
            rotation=180,
            origin={807,178})));
      Components.Harness.Cable cable62(harnessConfig(cableResistance=0.0001, L=
              0.0757e-6)) annotation (Placement(transformation(
            extent={{-17,-10},{17,10}},
            rotation=180,
            origin={815,98})));
      Components.Harness.Cable cable63(harnessConfig(cableResistance=0.0004, L=
              0.2333e-6)) annotation (Placement(transformation(
            extent={{-17,-10},{17,10}},
            rotation=180,
            origin={903,-268})));
      Components.Consumer.dummyLoad dummyLoad14 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={1000,-418})));
      Components.Consumer.dummyLoad dummyLoad15 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={1048,-236})));
      Components.Harness.GroundBolt groundBolt16 annotation (Placement(
            transformation(extent={{1212,-396},{1234,-372}})));
      Components.Consumer.dummyLoad dummyLoad16 annotation (Placement(
            transformation(
            extent={{10,-10},{-10,10}},
            rotation=180,
            origin={1046,-50})));
      Components.Fuse.Fuse2 conventionalFuse_Stage3_30 annotation (Placement(
            transformation(
            extent={{-26,-20},{26,20}},
            rotation=180,
            origin={946,-270})));

      Components.Harness.GroundBolt groundBolt17 annotation (Placement(
            transformation(extent={{1234,-220},{1256,-196}})));
      Components.Harness.GroundBolt groundBolt18
        annotation (Placement(transformation(extent={{1216,-40},{1238,-16}})));
      Components.Harness.Cable cable12(harnessConfig(cableResistance=0.000228,
            L=0.2018e-6))
        annotation (Placement(transformation(extent={{362,206},{396,226}})));
      Components.Fuse.Fuse2 eFuse_S2_1 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={1034,276})));
      Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={986,276})));
      Components.AbsolutePotential absolutePotential annotation (Placement(
            transformation(extent={{-15,-12},{15,12}}, origin={963,242})));
      Modelica.Electrical.Analog.Sensors.CurrentSensor currentSensor2
                                                                     annotation (Placement(transformation(
            extent={{-10,-10},{10,10}},
            rotation=0,
            origin={996,156})));
      Components.Fuse.Fuse2 eFuse_S2_6 annotation (Placement(transformation(
            extent={{-14,-8},{14,8}},
            rotation=0,
            origin={1048,156})));
      Components.AbsolutePotential absolutePotential1 annotation (Placement(
            transformation(extent={{-15,-12},{15,12}}, origin={971,136})));
      Components.Harness.Cable cable13(harnessConfig(cableResistance=0.1396, L=
              4.368e-6))
        annotation (Placement(transformation(extent={{296,-374},{330,-354}})));
      Components.Fuse.Fuse2 eFuse_S2_7
        annotation (Placement(transformation(extent={{-74,214},{-46,230}})));
      Components.Fuse.Fuse1 eFuse_S2_8(limit(y=98))
        annotation (Placement(transformation(extent={{-74,178},{-46,194}})));
      Components.Fuse.Fuse2 eFuse_S2_9
        annotation (Placement(transformation(extent={{-74,142},{-46,158}})));
      Components.Fuse.Fuse2 eFuse_S2_10
        annotation (Placement(transformation(extent={{-74,106},{-46,122}})));
      Components.Fuse.Fuse2 eFuse_S2_11
        annotation (Placement(transformation(extent={{426,-188},{454,-172}})));
      Components.Fuse.Fuse2 eFuse_S2_12
        annotation (Placement(transformation(extent={{428,-224},{456,-208}})));
      Components.Fuse.Fuse2 eFuse_S2_13
        annotation (Placement(transformation(extent={{426,-260},{454,-244}})));
      Components.Fuse.Fuse2 eFuse_S2_14
        annotation (Placement(transformation(extent={{426,-296},{454,-280}})));
      Components.Fuse.Fuse2 eFuse_S2_15
        annotation (Placement(transformation(extent={{426,-332},{454,-316}})));
      Components.Fuse.Fuse2 eFuse_S2_17
        annotation (Placement(transformation(extent={{-88,-204},{-60,-188}})));
      Components.Fuse.Fuse2 eFuse_S2_18
        annotation (Placement(transformation(extent={{-88,-240},{-60,-224}})));
      Components.Fuse.Fuse2 eFuse_S2_19
        annotation (Placement(transformation(extent={{-88,-276},{-60,-260}})));
      Components.Fuse.Fuse2 eFuse_S2_20
        annotation (Placement(transformation(extent={{-88,-312},{-60,-296}})));
      Components.Fuse.Fuse2 eFuse_S2_21
        annotation (Placement(transformation(extent={{-88,-348},{-60,-332}})));
      Components.Fuse.Fuse2 eFuse_S2_22
        annotation (Placement(transformation(extent={{-88,-384},{-60,-368}})));
      Components.Fuse.Fuse2 eFuse_S2_23
        annotation (Placement(transformation(extent={{-88,-420},{-60,-404}})));
      Components.Harness.Cable cable16(harnessConfig(cableResistance=0.01, L=
              1.291e-6)) annotation (Placement(transformation(extent={{-192,-422},
                {-158,-402}})));
      Components.Harness.Cable cable17(harnessConfig(cableResistance=0.007, L=
              1.26e-6)) annotation (Placement(transformation(extent={{-192,-242},
                {-158,-222}})));
      Components.Harness.Cable cable18(harnessConfig(cableResistance=0.01, L=
              1.2951e-6)) annotation (Placement(transformation(extent={{-192,-278},
                {-158,-258}})));
      Components.Harness.Cable cable19(harnessConfig(cableResistance=0.0066, L=
              1.19979e-6)) annotation (Placement(transformation(extent={{-192,-350},
                {-158,-330}})));
      Components.Harness.Cable cable20(harnessConfig(cableResistance=0.0486, L=
              1.5201e-6))
        annotation (Placement(transformation(extent={{468,-406},{502,-386}})));
      Components.Harness.Cable cable21(harnessConfig(cableResistance=0.1624, L=
              2.61e-6))
        annotation (Placement(transformation(extent={{592,-190},{626,-170}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput(
          consumer_S4_Rec(
          L=2.2e-6,
          R_L=2e-5,
          C2=0.0001,
          R_C2=0.34,
          C1=0.001701,
          R_C1=0.015))
        annotation (Placement(transformation(extent={{10,244},{80,274}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput(consumer_S4_Rec(
            C2=0.00116, R_C2=0.008))
        annotation (Placement(transformation(extent={{10,208},{80,238}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput1(
          consumer_S4_Rec(
          L=4.7e-6,
          R_L=0.078,
          C1=5e-6,
          R_C1=0.0146,
          C2=0.00066,
          R_C2=0.0395,
          R_consumer=14.91,
          scTime=0.001))
        annotation (Placement(transformation(extent={{10,172},{80,202}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput2(
          consumer_S4_Rec(
          L=6.8e-7,
          R_L=0.0035,
          C1=0.00033,
          R_C1=0.05,
          C2=0.00132,
          R_C2=0.0207,
          R_consumer=1.48))
        annotation (Placement(transformation(extent={{10,136},{80,166}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput3(
          consumer_S4_Rec(
          L=2.8e-6,
          R_L=0.0013,
          C1=0.00033,
          R_C1=0.016,
          C2=0.0078,
          R_C2=0.0075,
          R_consumer=1.75))
        annotation (Placement(transformation(extent={{10,100},{80,130}})));
      Components.Consumer.Consumer_S4_Left_T_Input consumer_S4_Left_T_Input(
        consumer_S4_Rec(
          L=1.899e-6,
          R_L=0.00567,
          C2=0.002,
          R_C2=0.01),
        capacitorC(v(fixed=true, start=12)),
        derivative(initType=Modelica.Blocks.Types.Init.InitialState))
        annotation (Placement(transformation(extent={{-186,-60},{-116,-30}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput4(
          consumer_S4_Rec(
          L=3.6e-6,
          R_L=0.0028,
          C1=0.000022,
          R_C1=1e-3,
          C2=0.00044,
          R_C2=1e-3))
        annotation (Placement(transformation(extent={{1072,-42},{1142,-12}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput5(
          consumer_S4_Rec(
          L=6.16e-5,
          R_L=0.0014,
          C1=6.6e-6,
          R_C1=0.0027,
          C2=0.00154,
          R_C2=0.0021)) annotation (Placement(transformation(extent={{1072,-222},
                {1142,-192}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput1(
          consumer_S4_Rec(R_consumer=4.07)) annotation (Placement(
            transformation(extent={{1072,-398},{1142,-368}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput6(
          consumer_S4_Rec(
          L=1e-6,
          R_L=0.023,
          C1=0.00034,
          R_C1=0.05,
          C2=5e-5,
          R_C2=1e-3))
        annotation (Placement(transformation(extent={{-4,-174},{66,-144}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput7(
          consumer_S4_Rec(
          L=1.5e-6,
          R_L=8e-6,
          C1=7.27e-5,
          R_C1=0.01,
          C2=7.27e-5,
          R_C2=0.01,
          R_consumer=0.90))
        annotation (Placement(transformation(extent={{-4,-210},{66,-180}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput2
        annotation (Placement(transformation(extent={{-4,-246},{66,-216}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput8(
          consumer_S4_Rec(
          L=1.5e-6,
          R_L=8e-6,
          C1=7.27e-5,
          R_C1=0.01,
          C2=7.27e-5,
          R_C2=0.01,
          R_consumer=0.92))
        annotation (Placement(transformation(extent={{-4,-282},{66,-252}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput9(
          consumer_S4_Rec(
          L=5.2e-6,
          R_L=0.0062,
          C1=2.35e-6,
          R_C1=0.001,
          C2=0.00054,
          R_C2=0.01,
          R_consumer=4.08))
        annotation (Placement(transformation(extent={{-4,-318},{66,-288}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput3(
          consumer_S4_Rec(R_consumer=3.34))
        annotation (Placement(transformation(extent={{-4,-354},{66,-324}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput4
        annotation (Placement(transformation(extent={{-4,-390},{66,-360}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput10(
          consumer_S4_Rec(
          L=3.299e-6,
          R_L=1.54e-5,
          C1=6.8199e-5,
          R_C1=1e-5,
          C2=2.02e-5,
          R_C2=1e-5,
          R_consumer=5.13))
        annotation (Placement(transformation(extent={{-4,-426},{66,-396}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput11(
          consumer_S4_Rec(
          L=1.5e-6,
          R_L=8e-6,
          C1=7.27e-5,
          R_C1=0.01,
          C2=7.27e-5,
          R_C2=0.01))
        annotation (Placement(transformation(extent={{510,-374},{580,-344}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput12(
          consumer_S4_Rec(
          L=1.5e-6,
          R_L=8e-6,
          C1=7.27e-5,
          R_C1=0.01,
          C2=7.27e-5,
          R_C2=0.01))
        annotation (Placement(transformation(extent={{510,-410},{580,-380}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput13(
          consumer_S4_Rec(
          L=1e-5,
          R_L=0.005,
          C1=2.5e-6,
          R_C1=0.01,
          C2=0.0001,
          R_C2=0.044,
          R_consumer=40.59))
        annotation (Placement(transformation(extent={{510,-302},{580,-272}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput15(
          consumer_S4_Rec(
          L=4.7e-6,
          R_L=0.05,
          C1=1e-7,
          R_C1=1e-3,
          C2=2.01e-5,
          R_C2=1e-3,
          R_consumer=44.86))
        annotation (Placement(transformation(extent={{510,-230},{580,-200}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput5(
          consumer_S4_Rec(R_consumer=0.79))
        annotation (Placement(transformation(extent={{510,-338},{580,-308}})));
      Components.Consumer.Consumer_S4_TInput consumer_S4_TInput6(
          consumer_S4_Rec(R_consumer=1225.06))
        annotation (Placement(transformation(extent={{510,-266},{580,-236}})));
      Components.Consumer.Consumer_S4_PhiInput consumer_S4_PhiInput14(
          consumer_S4_Rec(
          L=1.1e-5,
          R_L=0.055,
          C1=0.00010792,
          R_C1=0.00245,
          C2=0.00034832,
          R_C2=0.001572,
          R_consumer=6.73))
        annotation (Placement(transformation(extent={{510,-194},{580,-164}})));
    equation
      connect(G1_BATTERIE.p, cable.p) annotation (Line(
          points={{-352,134},{-386,134},{-386,-46},{-378,-46}},
          color={0,0,255},
          thickness=1));
      connect(cable.n, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{-344,-46},{-286,-46},{-286,-45},{-276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(conventionalFuse_Stage3_1.n, cable1.p) annotation (Line(points={{
              -237.714,-45},{-237.714,-46},{-230,-46}},      color={0,0,255}));
      connect(G1_BATTERIE.p, cable3.p) annotation (Line(
          points={{-352,134},{-388,134},{-388,222},{-354,222}},
          color={0,0,255},
          thickness=1));
      connect(cable7.n, groundBolt1.p) annotation (Line(points={{126,150},{
              144,150},{144,222},{178,222}}, color={0,0,0}));
      connect(cable5.n, groundBolt1.p) annotation (Line(points={{126,186},{
              144,186},{144,222},{178,222}}, color={0,0,0}));
      connect(cable15.n, groundBolt1.p)
        annotation (Line(points={{126,222},{178,222}}, color={0,0,0}));
      connect(cable9.n, cable10.p) annotation (Line(points={{126,114},{172,
              114},{172,128},{171,128}}, color={0,0,0}));
      connect(cable10.n, groundBolt2.p) annotation (Line(points={{171,160},{
              171,186},{178,186}}, color={0,0,0}));
      connect(groundBolt4.p, cable11.n)
        annotation (Line(points={{-282,134},{-290,134}}, color={0,0,255}));
      connect(G1_BATTERIE.n, cable11.p)
        annotation (Line(points={{-332,134},{-324,134}}, color={0,0,255}));
      connect(groundBolt4.n, groundBolt2.n) annotation (Line(
          points={{-260,134},{-206,134},{-206,52},{242,52},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));

      connect(groundBolt1.n, groundBolt2.n) annotation (Line(
          points={{200,222},{242,222},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt3.n, groundBolt2.n) annotation (Line(
          points={{200,258},{242,258},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(cable25.n, cable27.n) annotation (Line(points={{112,-268},{124,
              -268},{124,-304},{112,-304}}, color={0,0,0}));
      connect(cable29.n, cable33.n) annotation (Line(points={{112,-196},{134,
              -196},{134,-412},{112,-412}}, color={0,0,0}));
      connect(cable31.n, groundBolt10.p)
        annotation (Line(points={{112,-376},{150,-376}}, color={0,0,0}));
      connect(cable37.n, groundBolt9.p)
        annotation (Line(points={{112,-340},{150,-340}}, color={0,0,0}));
      connect(groundBolt8.p, cable27.n) annotation (Line(points={{150,-268},{
              124,-268},{124,-304},{112,-304}}, color={0,0,0}));
      connect(groundBolt6.p, cable33.n) annotation (Line(points={{150,-196},{
              134,-196},{134,-412},{112,-412}}, color={0,0,0}));
      connect(groundBolt4.n, ground.p) annotation (Line(points={{-260,134},{
              -248,134},{-248,110}}, color={0,0,0},
          thickness=1));
      connect(cable34.n, groundBolt5.p)
        annotation (Line(points={{178,-160},{186,-160}}, color={0,0,255}));
      connect(cable23.n, groundBolt7.p)
        annotation (Line(points={{112,-232},{150,-232}}, color={0,0,0}));
      connect(groundBolt5.n, groundBolt2.n) annotation (Line(
          points={{208,-160},{242,-160},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt6.n, groundBolt2.n) annotation (Line(
          points={{172,-196},{242,-196},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt7.n, groundBolt2.n) annotation (Line(
          points={{172,-232},{242,-232},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt8.n, groundBolt2.n) annotation (Line(
          points={{172,-268},{242,-268},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt9.n, groundBolt2.n) annotation (Line(
          points={{172,-340},{242,-340},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt10.n, groundBolt2.n) annotation (Line(
          points={{172,-376},{242,-376},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt11.p, cable2.n)
        annotation (Line(points={{-52,-46},{-72,-46}}, color={0,0,0}));
      connect(groundBolt11.n, groundBolt2.n) annotation (Line(
          points={{-30,-46},{-20,-46},{-20,52},{242,52},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));

      connect(cable50.n, dummyLoad13.p) annotation (Line(points={{318,-398},{
              366,-398},{366,-410},{384,-410}}, color={0,0,255}));
      connect(cable51.n, dummyLoad9.p) annotation (Line(points={{330,-256},{
              366,-256},{366,-270},{384,-270}}, color={0,0,255}));
      connect(cable52.n, dummyLoad11.p) annotation (Line(points={{330,-330},{
              364,-330},{364,-342},{384,-342}},                       color={
              0,0,255}));
      connect(dummyLoad7.p, conventionalFuse_Stage3_23.p) annotation (Line(
            points={{460,258},{438,258},{438,259},{440,259},{440,204},{540,204},
              {540,179},{514.286,179}},             color={0,0,255}));
      connect(conventionalFuse_Stage3_24.p, conventionalFuse_Stage3_23.p)
        annotation (Line(points={{514.286,137},{540,137},{540,179},{514.286,179}},
                                 color={0,0,255}));
      connect(conventionalFuse_Stage3_25.p, conventionalFuse_Stage3_23.p)
        annotation (Line(points={{514.286,99},{540,99},{540,179},{514.286,179}},
                                 color={0,0,255}));
      connect(conventionalFuse_Stage3_26.p, conventionalFuse_Stage3_23.p)
        annotation (Line(points={{514.286,59},{540,59},{540,179},{514.286,179}},
                                 color={0,0,255}));
      connect(cable43.n, groundBolt15.p)
        annotation (Line(points={{626,-324},{680,-324}}, color={0,0,0}));
      connect(cable41.n, groundBolt14.p) annotation (Line(points={{626,-288},
              {680,-288},{680,-288}}, color={0,0,0}));
      connect(cable47.n, groundBolt14.p) annotation (Line(points={{626,-360},
              {652,-360},{652,-288},{680,-288}}, color={0,0,0}));
      connect(cable49.n, groundBolt14.p) annotation (Line(points={{626,-396},
              {652,-396},{652,-288},{680,-288}}, color={0,0,0}));
      connect(cable45.n, groundBolt13.p)
        annotation (Line(points={{626,-216},{680,-216}}, color={0,0,0}));
      connect(cable39.n, groundBolt12.p) annotation (Line(points={{626,-252},
              {650,-252},{650,-180},{680,-180}}, color={0,0,0}));
      connect(groundBolt12.n, groundBolt2.n) annotation (Line(
          points={{702,-180},{794,-180},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt14.n, groundBolt2.n) annotation (Line(
          points={{702,-288},{794,-288},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt15.n, groundBolt2.n) annotation (Line(
          points={{702,-324},{794,-324},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt13.n, groundBolt2.n) annotation (Line(
          points={{702,-216},{794,-216},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad7.n, groundBolt2.n) annotation (Line(
          points={{480,258},{694,258},{694,-24},{242,-24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));

      connect(conventionalFuse_Stage3_27.n, cable55.p) annotation (Line(
            points={{1022.29,-27},{1022.29,-28},{1030,-28}},      color={0,0,
              255}));
      connect(conventionalFuse_Stage3_28.n, cable57.p) annotation (Line(
            points={{1020.29,-207},{1020.29,-208},{1028,-208}},     color={0,
              0,255}));
      connect(conventionalFuse_Stage3_29.n, cable59.p) annotation (Line(
            points={{1020.29,-383},{1020.29,-384},{1028,-384}},     color={0,
              0,255}));
      connect(cable63.n, conventionalFuse_Stage3_29.p) annotation (Line(
          points={{886,-268},{872,-268},{872,-383},{981.714,-383}},
          color={0,0,255},
          thickness=1));
      connect(dummyLoad15.p, conventionalFuse_Stage3_28.p) annotation (Line(
            points={{1038,-236},{972,-236},{972,-208},{981.714,-208},{981.714,
              -207}},     color={0,0,255},
          thickness=1));
      connect(dummyLoad14.n, groundBolt2.n) annotation (Line(
          points={{1010,-418},{1260,-418},{1260,-452},{794,-452},{794,-24},{
              242,-24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(cable60.n, groundBolt16.p) annotation (Line(points={{1186,-384},
              {1212,-384}},             color={0,0,255}));
      connect(groundBolt16.n, groundBolt2.n) annotation (Line(
          points={{1234,-384},{1260,-384},{1260,-452},{794,-452},{794,-24},{
              242,-24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(conventionalFuse_Stage3_30.p, conventionalFuse_Stage3_28.p)
        annotation (Line(
          points={{964.571,-270},{972,-270},{972,-208},{981.714,-208},{981.714,
              -207}},
          color={0,0,255},
          thickness=1));
      connect(conventionalFuse_Stage3_30.n, cable63.p) annotation (Line(
            points={{927.429,-270},{927.429,-268},{920,-268}},   color={0,0,
              255}));
      connect(dummyLoad15.n, groundBolt2.n) annotation (Line(
          points={{1058,-236},{1260,-236},{1260,-452},{794,-452},{794,-24},{
              242,-24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(cable58.n, groundBolt17.p)
        annotation (Line(points={{1186,-208},{1234,-208}}, color={0,0,0}));
      connect(dummyLoad16.n, groundBolt2.n) annotation (Line(
          points={{1056,-50},{1248,-50},{1248,-126},{794,-126},{794,-24},{242,
              -24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(cable56.n, groundBolt18.p)
        annotation (Line(points={{1188,-28},{1216,-28}}, color={0,0,255}));
      connect(groundBolt18.n, groundBolt2.n) annotation (Line(
          points={{1238,-28},{1248,-28},{1248,-126},{794,-126},{794,-24},{242,
              -24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(groundBolt17.n, groundBolt2.n) annotation (Line(
          points={{1256,-208},{1260,-208},{1260,-452},{794,-452},{794,-24},{
              242,-24},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad14.p, conventionalFuse_Stage3_29.p) annotation (Line(
          points={{990,-418},{966,-418},{966,-383},{981.714,-383}},
          color={0,0,255},
          thickness=1));
      connect(dummyLoad1.n, groundBolt2.n) annotation (Line(
          points={{-108,206},{242,206},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad2.n, groundBolt2.n) annotation (Line(
          points={{-108,170},{242,170},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad.n, groundBolt2.n) annotation (Line(
          points={{-264,-74},{-20,-74},{-20,52},{242,52},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));

      connect(battery.n, groundBolt2.n) annotation (Line(
          points={{-326,-216},{-250,-216},{-250,-86},{-20,-86},{-20,52},{242,52},{242,
              186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad6.n, groundBolt2.n) annotation (Line(
          points={{-118,-356},{242,-356},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad4.n, groundBolt2.n) annotation (Line(
          points={{-118,-284},{242,-284},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad3.n, groundBolt2.n) annotation (Line(
          points={{-118,-250},{242,-250},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad5.n, groundBolt2.n) annotation (Line(
          points={{-118,-430},{242,-430},{242,186},{200,186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad16.p, conventionalFuse_Stage3_27.p) annotation (Line(
          points={{1036,-50},{972,-50},{972,-28},{983.714,-28},{983.714,-27}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_1.p, currentSensor.n)
        annotation (Line(points={{1024,276},{1012,276},{1012,276},{996,276}},
                                                        color={0,0,255}));
      connect(currentSensor2.n, eFuse_S2_6.p)
        annotation (Line(points={{1006,156},{1024,156},{1024,156},{1038,156}},
                                                         color={0,0,255}));
      connect(cable12.n, conventionalFuse_Stage3_23.p) annotation (Line(
            points={{396,216},{440,216},{440,204},{540,204},{540,179},{514.286,
              179}},                                color={0,0,255}));
      connect(conventionalFuse_Stage3_23.n, cable52.p) annotation (Line(
          points={{475.714,179},{475.714,182},{260,182},{260,-330},{296,-330}},
          color={0,0,255},
          thickness=1));
      connect(conventionalFuse_Stage3_24.n, cable53.p) annotation (Line(
          points={{475.714,137},{268,137},{268,-288},{296,-288}},
          color={0,0,255},
          thickness=1));
      connect(conventionalFuse_Stage3_25.n, cable51.p) annotation (Line(
          points={{475.714,99},{280,99},{280,-256},{296,-256}},
          color={0,0,255},
          thickness=1));
      connect(conventionalFuse_Stage3_26.n, cable54.p) annotation (Line(
          points={{475.714,59},{288,59},{288,-218},{296,-218}},
          color={0,0,255},
          thickness=1));
      connect(cable12.p, currentSensor.p) annotation (Line(
          points={{362,216},{320,216},{320,326},{904,326},{904,276},{976,276}},
          color={0,0,255},
          thickness=1));

      connect(battery.p, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{-346,-216},{-412,-216},{-412,-154},{-308,-154},{-308,-46},{
              -286,-46},{-286,-45},{-276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(dummyLoad.p, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{-284,-74},{-288,-74},{-288,-46},{-286,-46},{-286,-46.4615},{
              -276.286,-46.4615},{-276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(absolutePotential.pin_p, currentSensor.p) annotation (Line(
            points={{947.9,244.1},{926,244.1},{926,244},{904,244},{904,276},{
              976,276}}, color={0,0,255}));
      connect(currentSensor2.p, currentSensor.p) annotation (Line(
          points={{986,156},{904,156},{904,276},{976,276}},
          color={0,0,255},
          thickness=1));
      connect(absolutePotential1.pin_p, currentSensor.p) annotation (Line(
            points={{955.9,138.1},{904,138.1},{904,276},{976,276}}, color={0,
              0,255}));
      connect(cable54.n, dummyLoad8.p) annotation (Line(points={{330,-218},{
              366,-218},{366,-232},{384,-232}}, color={0,0,255}));
      connect(dummyLoad8.n, groundBolt2.n) annotation (Line(
          points={{404,-232},{794,-232},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad9.n, groundBolt2.n) annotation (Line(
          points={{404,-270},{794,-270},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(cable53.n, dummyLoad10.p) annotation (Line(points={{330,-288},{
              360,-288},{360,-306},{384,-306}}, color={0,0,255}));
      connect(dummyLoad10.n, groundBolt2.n) annotation (Line(
          points={{404,-306},{794,-306},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad11.n, groundBolt2.n) annotation (Line(
          points={{404,-342},{794,-342},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad12.n, groundBolt2.n) annotation (Line(
          points={{404,-378},{794,-378},{794,-24},{242,-24},{242,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad13.n, groundBolt2.n) annotation (Line(
          points={{404,-410},{800,-410},{800,-24},{248,-24},{248,186},{200,
              186}},
          color={0,0,0},
          thickness=1));
      connect(dummyLoad7.p, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{460,258},{432,258},{432,256},{266,256},{266,312},{-412,312},
              {-412,-130},{-308,-130},{-308,-46},{-286,-46},{-286,-45},{
              -276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_7.n, cable14.p)
        annotation (Line(points={{-50,222},{-44,222},{-44,222},{-32,222}},
                                                       color={0,0,255}));
      connect(eFuse_S2_8.n, cable4.p)
        annotation (Line(points={{-54.26,185.385},{-44,185.385},{-44,186},{-32,
              186}},                                   color={0,0,255}));
      connect(eFuse_S2_9.n, cable6.p)
        annotation (Line(points={{-50,150},{-44,150},{-44,150},{-32,150}},
                                                       color={0,0,255}));
      connect(eFuse_S2_10.n, cable8.p)
        annotation (Line(points={{-50,114},{-44,114},{-44,114},{-32,114}},
                                                       color={0,0,255}));
      connect(cable3.n, eFuse_S2_7.p) annotation (Line(
          points={{-320,222},{-194,222},{-194,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_10.p, eFuse_S2_7.p) annotation (Line(
          points={{-70,114},{-92,114},{-92,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_9.p, eFuse_S2_7.p) annotation (Line(
          points={{-70,150},{-92,150},{-92,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(dummyLoad1.p, eFuse_S2_7.p) annotation (Line(
          points={{-128,206},{-146,206},{-146,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_8.p, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{-67.28,185.385},{-398,185.385},{-398,-84},{-308,-84},{-308,
              -46},{-286,-46},{-286,-46.4615},{-276.286,-46.4615},{-276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(dummyLoad2.p, conventionalFuse_Stage3_1.p) annotation (Line(
          points={{-128,170},{-146,170},{-146,186},{-398,186},{-398,-84},{-308,
              -84},{-308,-46},{-286,-46},{-286,-46.4615},{-276.286,-46.4615},{
              -276.286,-45}},
          color={0,0,255},
          thickness=1));
      connect(cable13.n, dummyLoad12.p) annotation (Line(points={{330,-364},{
              366,-364},{366,-378},{384,-378}}, color={0,0,255}));
      connect(eFuse_S2_23.n, cable32.p)
        annotation (Line(points={{-64,-412},{-58,-412},{-58,-412},{-46,-412}},
                                                         color={0,0,255}));
      connect(eFuse_S2_22.n, cable30.p)
        annotation (Line(points={{-64,-376},{-58,-376},{-58,-376},{-46,-376}},
                                                         color={0,0,255}));
      connect(eFuse_S2_21.n, cable36.p)
        annotation (Line(points={{-64,-340},{-58,-340},{-58,-340},{-46,-340}},
                                                         color={0,0,255}));
      connect(eFuse_S2_20.n, cable26.p)
        annotation (Line(points={{-64,-304},{-58,-304},{-58,-304},{-46,-304}},
                                                         color={0,0,255}));
      connect(eFuse_S2_19.n, cable24.p)
        annotation (Line(points={{-64,-268},{-58,-268},{-58,-268},{-46,-268}},
                                                         color={0,0,255}));
      connect(eFuse_S2_18.n, cable22.p)
        annotation (Line(points={{-64,-232},{-58,-232},{-58,-232},{-46,-232}},
                                                         color={0,0,255}));
      connect(dummyLoad3.p, eFuse_S2_18.p) annotation (Line(points={{-138,-250},
              {-150,-250},{-150,-232},{-84,-232}},       color={0,0,255}));
      connect(dummyLoad4.p, eFuse_S2_19.p) annotation (Line(points={{-138,-284},
              {-150,-284},{-150,-268},{-84,-268}},       color={0,0,255}));
      connect(eFuse_S2_20.p, eFuse_S2_21.p) annotation (Line(points={{-84,-304},
              {-106,-304},{-106,-340},{-84,-340}},       color={0,0,255}));
      connect(dummyLoad6.p, eFuse_S2_21.p) annotation (Line(points={{-138,-356},
              {-150,-356},{-150,-340},{-84,-340}},       color={0,0,255}));
      connect(cable13.p, eFuse_S2_21.p) annotation (Line(
          points={{296,-364},{254,-364},{254,-462},{-266,-462},{-266,-374},{
              -150,-374},{-150,-340},{-84,-340}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_22.p, eFuse_S2_23.p) annotation (Line(points={{-84,-376},
              {-106,-376},{-106,-412},{-84,-412}},       color={0,0,255}));
      connect(dummyLoad5.p, eFuse_S2_23.p) annotation (Line(points={{-138,-430},
              {-150,-430},{-150,-412},{-84,-412}},       color={0,0,255}));
      connect(eFuse_S2_5.n, cable16.p)
        annotation (Line(points={{-202,-412},{-200,-412},{-200,-412},{-192,-412}},
                                                           color={0,0,255}));
      connect(cable16.n, eFuse_S2_23.p)
        annotation (Line(points={{-158,-412},{-120,-412},{-120,-412},{-84,-412}},
                                                          color={0,0,255}));
      connect(eFuse_S2_2.n, cable17.p)
        annotation (Line(points={{-202,-232},{-200,-232},{-200,-232},{-192,-232}},
                                                           color={0,0,255}));
      connect(cable17.n, eFuse_S2_18.p)
        annotation (Line(points={{-158,-232},{-120,-232},{-120,-232},{-84,-232}},
                                                          color={0,0,255}));
      connect(eFuse_S2_4.n, cable18.p)
        annotation (Line(points={{-202,-268},{-200,-268},{-200,-268},{-192,-268}},
                                                           color={0,0,255}));
      connect(cable18.n, eFuse_S2_19.p)
        annotation (Line(points={{-158,-268},{-120,-268},{-120,-268},{-84,-268}},
                                                          color={0,0,255}));
      connect(cable19.n, eFuse_S2_21.p)
        annotation (Line(points={{-158,-340},{-120,-340},{-120,-340},{-84,-340}},
                                                          color={0,0,255}));
      connect(cable19.p, eFuse_S2_3.n)
        annotation (Line(points={{-192,-340},{-200,-340},{-200,-340},{-202,-340}},
                                                           color={0,0,255}));
      connect(cable50.p, eFuse_S2_23.p) annotation (Line(
          points={{284,-398},{280,-398},{280,-470},{-150,-470},{-150,-412},{-84,
              -412}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_3.p, eFuse_S2_7.p) annotation (Line(
          points={{-222,-340},{-238,-340},{-238,-108},{52,-108},{52,74},{-174,
              74},{-174,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_4.p, eFuse_S2_7.p) annotation (Line(
          points={{-222,-268},{-238,-268},{-238,-108},{52,-108},{52,74},{-174,
              74},{-174,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_2.p, eFuse_S2_7.p) annotation (Line(
          points={{-222,-232},{-238,-232},{-238,-108},{52,-108},{52,74},{-174,
              74},{-174,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(eFuse_S2_5.p, eFuse_S2_7.p) annotation (Line(
          points={{-222,-412},{-238,-412},{-238,-108},{52,-108},{52,74},{-174,
              74},{-174,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(cable61.p, eFuse_S2_1.n) annotation (Line(
          points={{824,178},{1172,178},{1172,276},{1044,276}},
          color={0,0,255},
          thickness=1));
      connect(cable61.n, conventionalFuse_Stage3_27.p) annotation (Line(
          points={{790,178},{754,178},{754,10},{854,10},{854,-28},{983.714,-28},
              {983.714,-27}},
          color={0,0,255},
          thickness=1));
      connect(cable62.p, eFuse_S2_6.n) annotation (Line(
          points={{832,98},{1176,98},{1176,156},{1058,156}},
          color={0,0,255},
          thickness=1));
      connect(cable62.n, conventionalFuse_Stage3_28.p) annotation (Line(
          points={{798,98},{774,98},{774,26},{826,26},{826,-208},{981.714,-208},
              {981.714,-207}},
          color={0,0,255},
          thickness=1));
      connect(cable21.n, groundBolt12.p)
        annotation (Line(points={{626,-180},{680,-180}}, color={0,0,0}));
      connect(groundBolt3.p, consumer_S4_PhiInput.n) annotation (Line(
          points={{178,258},{80.6176,258},{80.6176,257.929}},
          color={0,0,255},
          thickness=1));
      connect(consumer_S4_PhiInput.p, eFuse_S2_7.p) annotation (Line(
          points={{9.58824,257.929},{-92,257.929},{-92,222},{-70,222}},
          color={0,0,255},
          thickness=1));
      connect(consumer_S4_TInput.n, cable15.p) annotation (Line(points={{80.6176,
              221.929},{80.6176,222},{92,222}},         color={0,0,255}));
      connect(consumer_S4_TInput.p, cable14.n) annotation (Line(points={{9.58824,
              221.929},{9.58824,222},{2,222}},         color={0,0,255}));
      connect(consumer_S4_PhiInput1.n, cable5.p) annotation (Line(points={{80.6176,
              185.929},{92,185.929},{92,186}},         color={0,0,255}));
      connect(consumer_S4_PhiInput1.p, cable4.n) annotation (Line(points={{9.58824,
              185.929},{9.58824,186},{2,186}},         color={0,0,255}));
      connect(consumer_S4_PhiInput2.n, cable7.p) annotation (Line(points={{80.6176,
              149.929},{92,149.929},{92,150}},         color={0,0,255}));
      connect(consumer_S4_PhiInput2.p, cable6.n) annotation (Line(points={{9.58824,
              149.929},{9.58824,150},{2,150}},         color={0,0,255}));
      connect(consumer_S4_PhiInput3.p, cable8.n) annotation (Line(points={{9.58824,
              113.929},{9.58824,114},{2,114}},         color={0,0,255}));
      connect(consumer_S4_PhiInput3.n, cable9.p) annotation (Line(points={{80.6176,
              113.929},{80.6176,114},{92,114}},         color={0,0,255}));
      connect(cable1.n, consumer_S4_Left_T_Input.p) annotation (Line(points={{-196,
              -46},{-192,-46.0714},{-186.412,-46.0714}},       color={0,0,255}));
      connect(consumer_S4_Left_T_Input.n, cable2.p) annotation (Line(points={{
              -115.382,-46.0714},{-106,-46.0714},{-106,-46}},  color={0,0,255}));
      connect(cable55.n, consumer_S4_PhiInput4.p) annotation (Line(points={{1064,
              -28},{1068,-28},{1068,-28.0714},{1071.59,-28.0714}},      color
            ={0,0,255}));
      connect(consumer_S4_PhiInput4.n, cable56.p) annotation (Line(points={{1142.62,
              -28.0714},{1148,-28.0714},{1148,-28},{1154,-28}},         color
            ={0,0,255}));
      connect(cable57.n, consumer_S4_PhiInput5.p) annotation (Line(points={{1062,
              -208},{1064,-208.071},{1071.59,-208.071}},      color={0,0,255}));
      connect(consumer_S4_PhiInput5.n, cable58.p) annotation (Line(points={{1142.62,
              -208.071},{1152,-208.071},{1152,-208}},         color={0,0,255}));
      connect(consumer_S4_TInput1.n, cable60.p) annotation (Line(points={{1142.62,
              -384.071},{1144,-384},{1152,-384}},         color={0,0,255}));
      connect(consumer_S4_TInput1.p, cable59.n) annotation (Line(points={{1071.59,
              -384.071},{1062,-384.071},{1062,-384}},         color={0,0,255}));
      connect(cable34.p, consumer_S4_PhiInput6.n) annotation (Line(points={{144,
              -160},{132,-160},{132,-160.071},{66.6176,-160.071}},     color=
              {0,0,255}));
      connect(consumer_S4_PhiInput6.p, eFuse_S2_18.p) annotation (Line(points={{
              -4.41176,-160.071},{-4.41176,-160},{-108,-160},{-108,-232},{-84,
              -232}},     color={0,0,255}));
      connect(consumer_S4_PhiInput10.n, cable33.p) annotation (Line(points={{66.6176,
              -412.071},{66.6176,-412},{78,-412}},         color={0,0,255}));
      connect(consumer_S4_PhiInput10.p, cable32.n) annotation (Line(points={{
              -4.41176,-412.071},{-4.41176,-412},{-12,-412}}, color={0,0,255}));
      connect(consumer_S4_TInput4.p, cable30.n) annotation (Line(points={{
              -4.41176,-376.071},{-12,-376}}, color={0,0,255}));
      connect(consumer_S4_TInput4.n, cable31.p) annotation (Line(points={{66.6176,
              -376.071},{70,-376.071},{70,-376},{78,-376}},         color={0,
              0,255}));
      connect(consumer_S4_TInput3.n, cable37.p) annotation (Line(points={{66.6176,
              -340.071},{78,-340.071},{78,-340}},         color={0,0,255}));
      connect(cable36.n, consumer_S4_TInput3.p) annotation (Line(points={{-12,
              -340},{-8,-340},{-8,-340.071},{-4.41176,-340.071}}, color={0,0,
              255}));
      connect(consumer_S4_PhiInput9.n, cable27.p) annotation (Line(points={{66.6176,
              -304.071},{78,-304.071},{78,-304}},         color={0,0,255}));
      connect(consumer_S4_PhiInput9.p, cable26.n) annotation (Line(points={{
              -4.41176,-304.071},{-12,-304}}, color={0,0,255}));
      connect(consumer_S4_PhiInput8.n, cable25.p) annotation (Line(points={{66.6176,
              -268.071},{68,-268.071},{68,-268},{78,-268}},         color={0,
              0,255}));
      connect(cable24.n, consumer_S4_PhiInput8.p) annotation (Line(points={{-12,
              -268},{-8,-268.071},{-4.41176,-268.071}},     color={0,0,255}));
      connect(consumer_S4_TInput2.n, cable23.p) annotation (Line(points={{66.6176,
              -232.071},{78,-232.071},{78,-232}},         color={0,0,255}));
      connect(cable22.n, consumer_S4_TInput2.p) annotation (Line(points={{-12,
              -232},{-8,-232},{-8,-232.071},{-4.41176,-232.071}}, color={0,0,
              255}));
      connect(consumer_S4_PhiInput7.n, cable29.p) annotation (Line(points={{66.6176,
              -196.071},{78,-196.071},{78,-196}},         color={0,0,255}));
      connect(cable40.n, consumer_S4_TInput6.p) annotation (Line(points={{502,
              -252},{506,-252},{506,-252.071},{509.588,-252.071}}, color={0,0,
              255}));
      connect(consumer_S4_TInput6.n, cable39.p) annotation (Line(points={{580.618,
              -252.071},{592,-252.071},{592,-252}},         color={0,0,255}));
      connect(consumer_S4_PhiInput13.n, cable41.p) annotation (Line(points={{580.618,
              -288.071},{584,-288},{592,-288}},         color={0,0,255}));
      connect(cable42.n, consumer_S4_PhiInput13.p) annotation (Line(points={{502,
              -288},{504,-288.071},{509.588,-288.071}},     color={0,0,255}));
      connect(consumer_S4_TInput5.p, cable46.n) annotation (Line(points={{509.588,
              -324.071},{502,-324.071},{502,-324}},         color={0,0,255}));
      connect(consumer_S4_TInput5.n, cable43.p) annotation (Line(points={{580.618,
              -324.071},{592,-324.071},{592,-324}},         color={0,0,255}));
      connect(consumer_S4_PhiInput15.n, cable45.p) annotation (Line(points={{580.618,
              -216.071},{586,-216.071},{586,-216},{592,-216}},         color=
              {0,0,255}));
      connect(consumer_S4_PhiInput14.n, cable21.p) annotation (Line(points={{580.618,
              -180.071},{584,-180.071},{584,-180},{592,-180}},         color=
              {0,0,255}));
      connect(consumer_S4_PhiInput14.p, cable44.n) annotation (Line(points={{509.588,
              -180.071},{509.588,-180},{502,-180}},         color={0,0,255}));
      connect(cable35.n, consumer_S4_PhiInput15.p) annotation (Line(points={{502,
              -216},{504,-216.071},{509.588,-216.071}},     color={0,0,255}));
      connect(consumer_S4_PhiInput11.n, cable47.p) annotation (Line(points={{580.618,
              -360.071},{592,-360.071},{592,-360}},         color={0,0,255}));
      connect(cable20.n, consumer_S4_PhiInput12.p) annotation (Line(points={{502,
              -396},{502,-396.071},{509.588,-396.071}},     color={0,0,255}));
      connect(cable49.p, consumer_S4_PhiInput12.n) annotation (Line(points={{592,
              -396},{586,-396},{586,-396.071},{580.618,-396.071}},     color=
              {0,0,255}));
      connect(cable48.n, consumer_S4_PhiInput11.p) annotation (Line(points={{502,
              -360},{506,-360},{506,-360.071},{509.588,-360.071}},     color=
              {0,0,255}));
      connect(cable28.n, consumer_S4_PhiInput7.p) annotation (Line(points={{-12,
              -196},{-8,-196.071},{-4.41176,-196.071}},     color={0,0,255}));
      connect(eFuse_S2_17.p, eFuse_S2_18.p) annotation (Line(points={{-84,-196},
              {-108,-196},{-108,-232},{-84,-232}},       color={0,0,255}));
      connect(eFuse_S2_17.n, cable28.p)
        annotation (Line(points={{-64,-196},{-58,-196},{-58,-196},{-46,-196}},
                                                         color={0,0,255}));
      connect(cable46.p, eFuse_S2_15.n)
        annotation (Line(points={{468,-324},{456,-324},{456,-324},{450,-324}},
                                                         color={0,0,255}));
      connect(eFuse_S2_15.p, dummyLoad11.p) annotation (Line(points={{430,-324},
              {364,-324},{364,-342},{384,-342}},
                                            color={0,0,255}));
      connect(eFuse_S2_14.p, dummyLoad10.p) annotation (Line(points={{430,-288},
              {360,-288},{360,-306},{384,-306}},
                                            color={0,0,255}));
      connect(eFuse_S2_13.p, dummyLoad9.p) annotation (Line(points={{430,-252},
              {366,-252},{366,-270},{384,-270}},
                                            color={0,0,255}));
      connect(eFuse_S2_12.p, dummyLoad8.p) annotation (Line(points={{432,-216},
              {366,-216},{366,-232},{384,-232}},
                                            color={0,0,255}));
      connect(eFuse_S2_11.p, dummyLoad8.p) annotation (Line(points={{430,-180},
              {366,-180},{366,-232},{384,-232}},
                                            color={0,0,255}));
      connect(eFuse_S2_11.n, cable44.p)
        annotation (Line(points={{450,-180},{456,-180},{456,-180},{468,-180}},
                                                         color={0,0,255}));
      connect(eFuse_S2_12.n, cable35.p)
        annotation (Line(points={{452,-216},{458,-216},{458,-216},{468,-216}},
                                                         color={0,0,255}));
      connect(eFuse_S2_13.n, cable40.p)
        annotation (Line(points={{450,-252},{456,-252},{456,-252},{468,-252}},
                                                         color={0,0,255}));
      connect(eFuse_S2_14.n, cable42.p)
        annotation (Line(points={{450,-288},{456,-288},{456,-288},{468,-288}},
                                                         color={0,0,255}));
      connect(cable48.p, dummyLoad12.p) annotation (Line(points={{468,-360},{366,-360},
              {366,-378},{384,-378}}, color={0,0,255}));
      connect(cable20.p, dummyLoad13.p) annotation (Line(points={{468,-396},{366,-396},
              {366,-410},{384,-410}}, color={0,0,255}));
      annotation (Icon(coordinateSystem(preserveAspectRatio=false, extent={{
                -440,-500},{1280,340}})), Diagram(coordinateSystem(
              preserveAspectRatio=false, extent={{-440,-500},{1280,340}}),
            graphics={
            Rectangle(
              extent={{-294,-20},{-54,-90}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{-374,152},{-310,110}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{-192,282},{154,92}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{-184,-142},{140,-446}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{838,290},{1244,72}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{330,-148},{672,-434}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{300,288},{718,50}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{946,6},{1212,-66}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{950,-248},{1216,-168}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{948,-354},{1198,-438}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Polygon(
              points={{490,-484},{490,-484}},
              lineColor={0,0,255},
              lineThickness=1,
              fillColor={255,255,255},
              fillPattern=FillPattern.None),
            Rectangle(
              extent={{-366,-194},{-302,-236}},
              lineColor={0,0,0},
              fillColor={255,255,255},
              fillPattern=FillPattern.None,
              pattern=LinePattern.DashDot),
            Rectangle(
              extent={{8,204},{82,168}},
              lineColor={238,46,47},
              lineThickness=0.5,
              pattern=LinePattern.Dash),
            Text(
              extent={{84,204},{112,192}},
              textColor={238,46,47},
              textString="Short
Circuit",
              horizontalAlignment=TextAlignment.Left)}),
        experiment(
          StopTime=0.25,
          Interval=1e-06,
          Tolerance=1e-06,
          __Dymola_Algorithm="Dassl"),
        __Dymola_experimentSetupOutput(equidistant=false),
        __Dymola_experimentFlags(
          Advanced(
            GenerateAnalyticJacobian=false,
            GenerateVariableDependencies=true,
            OutputModelicaCode=false),
          Evaluate=false,
          OutputCPUtime=false,
          OutputFlatModelica=false));
    end scConsumer_Translator;
  end Models;
  annotation (uses(
      Modelica(version="4.0.0"),
      ENBN_CoSim_Lib_DBS_ModifiedComponents(version="1"),
      EPNDBS(version="2.1.0 dev")));
end TranslatorModelle;
