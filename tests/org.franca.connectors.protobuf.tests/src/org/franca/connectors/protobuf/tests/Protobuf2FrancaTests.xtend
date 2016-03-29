package org.franca.connectors.protobuf.tests

import com.google.inject.Inject
import java.util.List
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.compare.Diff
import org.eclipse.emf.compare.EMFCompare
import org.eclipse.emf.compare.internal.spec.ResourceAttachmentChangeSpec
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.JavaIoFileSystemAccess
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.franca.connectors.protobuf.Protobuf2FrancaDeploymentGenerator
import org.franca.connectors.protobuf.ProtobufConnector
import org.franca.connectors.protobuf.ProtobufModelContainer
import org.franca.core.dsl.FrancaIDLTestsInjectorProvider
import org.franca.core.dsl.FrancaPersistenceManager
import org.franca.deploymodel.core.FDModelExtender
import org.franca.deploymodel.core.FDeployedTypeCollection
import org.franca.deploymodel.dsl.FDeployPersistenceManager
import org.franca.deploymodel.dsl.fDeploy.FDModel
import org.junit.Ignore
import org.junit.Test
import org.junit.runner.RunWith

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(FrancaIDLTestsInjectorProvider))
class Protobuf2FrancaTests {

	val MODEL_DIR = "model/testcases/"
	val REF_DIR = "model/reference/"
	val GEN_DIR = "src-gen/testcases/"
	val DEPLOY_DIR = "model/deploy/"
	val SPEC_FILE = "../specification/ProtobufSpec.fdepl"

	@Inject extension FrancaPersistenceManager
	
	@Inject
	FDeployPersistenceManager loader
	
	@Inject
	JavaIoFileSystemAccess fsa
	
	@Inject
	Protobuf2FrancaDeploymentGenerator generator

	@Test
	def empty() {
		test("EmptyService")
		test("EmptyMessage")
	}
	
	@Test 
	def messageWithScalarValueTypeFields(){
		test("MessageWithScalarValueTypeFields")
	}

	@Test
	def serviceWithOneRPC(){
		test("ServiceWithOneRPC")
	}
	
	@Test
	def messageWithComplexTypeFields(){
		test("MessageWithComplexTypeFields")
	}
	
	@Test
	def messageWithComplexType(){
		test("MessageWithComplexType")
	}
	
	@Test
	def messageWithMessageField() {
		test("MessageWithMessageField")
	}

	@Test
	def oneOf() {
		test("MessageWithOneof")
	}
	
	@Test
	def extend() {
		test("MessageWithExtend")
	}
	
	@Test
	def extend_nested() {
		test("NestedExtensions")
	}
	
	@Test 
	def nameNotUnique(){
		test ("NameNotUnique")
	}
	
	@Test 
	def nestedTypes(){
		test ("NestedTypes")
	}
	
	@Test
	def test_Import() {
		test("MultiFiles")
	}

	@Test
	@Ignore
	//FIXME implicit import
	def option() {
		test("Option")
		//test("EnumWithOption")
	}
	
	@Test
	//FIXME Franca Serializer issues : the subtraction operator is separated from the number. 
	def enum_enumeratorValue(){
		test("Enum_enumeratorValue")
	}
	
	@Test
	def enum_emptyEnum(){
		test("Enum_emptyEnum")
	}

	/**
	 * Utility method for executing one transformation and comparing the result with a reference model.
	 */
	private def test(String inputfile) {
		val PROTOBUF_EXT = ".proto"
		val FRANCA_IDL_EXT = ".fidl"
		
		// load the OMG IDL input model
		val conn = new ProtobufConnector
		val protobufidl = conn.loadModel(MODEL_DIR + inputfile + PROTOBUF_EXT) as ProtobufModelContainer

		// do the actual transformation to Franca IDL and save the result
		val fmodelGen = conn.toFranca(protobufidl)
		EcoreUtil.resolveAll(fmodelGen)
		fmodelGen.saveModel(GEN_DIR + inputfile + FRANCA_IDL_EXT)
		
//		val uri = URI.createURI(GEN_DIR + inputfile + FRANCA_IDL_EXT)
//		fsa.generateFile(DEPLOY_DIR+ inputfile +".fdepl", compileDeploy(uri.trimSegments(0).toFileString))
//		
//		val FDModel fdmodel = loader.loadModel(DEPLOY_DIR+ inputfile +".fdepl")
//		assertNotNull(fdmodel)
//		
//		// get first provider definition referenced by FDeploy model
//		val FDModelExtender fdmodelExt = new FDModelExtender(fdmodel)
//		val typeCollections = fdmodelExt.FDTypesList
//		assertTrue(typeCollections.size>0)
//		val typeCollection = typeCollections.get(0)
//		
//		val FDeployedTypeCollection deployed = new FDeployedTypeCollection(typeCollection)
//		generator.generate(protobufidl.model,fmodelGen)
		
		
		// load the reference Franca IDL model
		val fmodelRef = loadModel(REF_DIR + inputfile + FRANCA_IDL_EXT)
		EcoreUtil.resolveAll(fmodelRef.eResource)

		// use EMF Compare to compare both Franca IDL models (the generated and the reference model)
		val rset2 = fmodelRef.eResource.resourceSet
		val rset1 = fmodelGen.eResource.resourceSet

		val scope = EMFCompare.createDefaultScope(rset1, rset2)
		val comparison = EMFCompare.builder.build.compare(scope)
		val List<Diff> differences = comparison.differences
		var nDiffs = 0
		for (diff : differences) {
			if (! (diff instanceof ResourceAttachmentChangeSpec)) {
				System.out.println(diff.toString)
				nDiffs++
			}
		}

		// TODO: is there a way to show the difference in a side-by-side view if the test fails?
		// (EMF Compare should provide a nice view for this...)		
		// we expect that both Franca IDL models are identical 
		assertEquals(0, nDiffs)
	}
	
	private def compileDeploy(String francaFile) '''
	import "�SPEC_FILE�"

	import "../�francaFile�"
	
	define org.franca.connectors.protobuf.tests.ProtobufSpec for typeCollection org.franca.connectors.protobuf.tests{
		
	}
	'''
}
