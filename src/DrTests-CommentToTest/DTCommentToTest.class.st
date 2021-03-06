Class {
	#name : #DTCommentToTest,
	#superclass : #DrTestsPlugin,
	#category : #'DrTests-CommentToTest'
}

{ #category : #'api - accessing' }
DTCommentToTest class >> pluginName [
	^ 'Comments to Tests'
]

{ #category : #'api - accessing' }
DTCommentToTest class >> weight [
	^ 20
]

{ #category : #api }
DTCommentToTest >> resultButtonHelp [
	^ 'Browse the test selected in the results list.' translated
]

{ #category : #api }
DTCommentToTest >> resultButtonLabel [
	^ 'Browse test' translated
]

{ #category : #api }
DTCommentToTest >> run [
	self runTests
]

{ #category : #api }
DTCommentToTest >> runSuite: aTestSuite withResult: aResult [
	aTestSuite
		subscribe: TestAnnouncement
		do: [ :testAnnouncement | self ui updateStatus: 'Running test {1}.' format: { testAnnouncement test asString } ].
	[ aTestSuite run: aResult  ] ensure: [
		aTestSuite unsubscribe:TestAnnouncement.
	].
]

{ #category : #api }
DTCommentToTest >> runTestSuites: testSuites [ 

|result|

	result := TestAsserter classForTestResult new.

	CurrentExecutionEnvironment runTestsBy: [
		testSuites
			do: [:testSuite | 
				self runSuite: testSuite withResult: result.]
			displayingProgress: 'Running Tests'.
	].
	^ result
]

{ #category : #api }
DTCommentToTest >> runTests [
	[
		|results cmdConf|
		self ui lock.
		self ui updateStatus: 'Tests started.'.
		cmdConf := DTCommentTestConfiguration testClasses: (self ui testsConfiguration testClasses). 
		results := (self runTestSuites: {cmdConf asTestSuite}) asResultsForDrTests.
		results subResults do: [ :resultGroup |
			resultGroup contextMenuBlock: [ :menu |
				menu
					addGroup: [ :group |
						group addItem: [ :item |
							item
								name: 'Re-run';
								action: [ "TODO: self reRunResultGroup: resultGroup" ] ] ] ] ].
		self ui results: results.
		self ui updateStatus: 'Tests finished.'.
	] ensure: [ self ui unlock ]
]

{ #category : #api }
DTCommentToTest >> selectClasesFrom: packagesSelected [
^(packagesSelected collect: [ :p | 
		p definedClasses select: [ :c | 
			c methods anySatisfy: [
					:m | ((m methodClass commentsAt: m selector) select: [ :com | com includesSubstring: '>>>']) isNotEmpty ] ]]).

]

{ #category : #api }
DTCommentToTest >> selectPackages [
^(RPackage organizer packages select: [ :p |
			p definedClasses anySatisfy: [ :c | c methods anySatisfy: [
					:m | m comment isNotNil and: [ ((m methodClass commentsAt: m selector) select: [ :com | com includesSubstring: '>>>']) isNotEmpty ]]]])
]

{ #category : #api }
DTCommentToTest >> startButtonHelp [
	^ 'Run tests selected.' translated
]

{ #category : #api }
DTCommentToTest >> startButtonLabel [
	^ 'Run Tests' translated
]
